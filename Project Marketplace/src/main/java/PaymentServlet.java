import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/payment/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/marketplace";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("text/html");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            res.sendRedirect("../login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");

        String method = req.getParameter("method");
        String amountStr = req.getParameter("amount");
        String projectIdStr = req.getParameter("projectId");

        if (method == null || amountStr == null || projectIdStr == null) {
            res.getWriter().println("Missing payment details.");
            return;
        }

        int amount, projectId;
        try {
            amount = Integer.parseInt(amountStr);
            projectId = Integer.parseInt(projectIdStr);
        } catch (NumberFormatException e) {
            res.getWriter().println("Invalid numeric input.");
            return;
        }

        // Payment validation
        boolean isValid = validatePayment(req, method);
        if (!isValid) {
            session.setAttribute("payment_success", false);
            res.sendRedirect("../payment.jsp");
            return;
        }

        String status = "success";

        try (
            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)
        ) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String query = "INSERT INTO client_payment " +
                    "(amount, method, user_id, project_id, status, created_at) " +
                    "VALUES (?, ?, ?, ?, ?, NOW())";

            try (PreparedStatement st = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {

                st.setInt(1, amount);
                st.setString(2, method);
                st.setInt(3, userId);
                st.setInt(4, projectId);
                st.setString(5, status);

                int rows = st.executeUpdate();

                if (rows > 0) {
                    ResultSet keys = st.getGeneratedKeys();
                    int paymentId = 0;
                    if (keys.next()) paymentId = keys.getInt(1);

                    session.setAttribute("payment_success", true);
                    res.sendRedirect("../bill.jsp?paymentId=" + paymentId);
                } else {
                    session.setAttribute("payment_success", false);
                    res.sendRedirect("../payment.jsp");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("payment_success", false);
            res.sendRedirect("../payment.jsp");
        }
    }

    // 🔐 Payment validation logic separated
    private boolean validatePayment(HttpServletRequest req, String method) {

        if ("upi".equalsIgnoreCase(method)) {
            String upi = req.getParameter("upi");
            return upi != null && upi.contains("@");
        }

        if ("debit".equalsIgnoreCase(method)) {
            String cardName = req.getParameter("cardholder_name");
            String cardNo = req.getParameter("card_no");
            String expiry = req.getParameter("expiry");
            String cvv = req.getParameter("cvv");

            return cardName != null && !cardName.isEmpty()
                    && cardNo != null && cardNo.matches("\\d{16}")
                    && expiry != null && !expiry.isEmpty()
                    && cvv != null && cvv.matches("\\d{3}");
        }

        return false;
    }
}
