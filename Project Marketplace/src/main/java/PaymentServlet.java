import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/payment/PaymentServlet")
public class PaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter pw = res.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            pw.println("Unauthorized access.");
            return;
        }

        int userId = (Integer) session.getAttribute("user_id");
        String method = req.getParameter("method");
        String amountStr = req.getParameter("amount");
        String projectIdStr = req.getParameter("projectId");

        if (method == null || amountStr == null || projectIdStr == null) {
            pw.println("Missing payment details.");
            return;
        }

        int projectId = 0;
        int amount = 0;

        try {
            projectId = Integer.parseInt(projectIdStr);
            amount = Integer.parseInt(amountStr);
        } catch (NumberFormatException e) {
            pw.println("Invalid numeric input.");
            return;
        }

        String status = "fail";
        boolean isPaymentValid = false;

        // Validate payment method and details
        String upi = req.getParameter("upi");
        String cardholderName = req.getParameter("cardholder_name");
        String cardNo = req.getParameter("card_no");
        String expiry = req.getParameter("expiry");
        String cvv = req.getParameter("cvv");

        if ("upi".equalsIgnoreCase(method)) {
            if (upi != null && !upi.trim().isEmpty() && upi.contains("@")) {
                isPaymentValid = true;
                status = "success";
            }
        } else if ("debit".equalsIgnoreCase(method)) {
            if (cardholderName != null && !cardholderName.trim().isEmpty()
                    && cardNo != null && cardNo.matches("\\d{16}")
                    && expiry != null && !expiry.trim().isEmpty()
                    && cvv != null && cvv.matches("\\d{3}")) {
                isPaymentValid = true;
                status = "success";
            }
        } else {
            pw.println("Invalid payment method.");
            return;
        }

        // Process payment
        if (isPaymentValid) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
                PreparedStatement st;

                if ("upi".equalsIgnoreCase(method)) {
                    String query = "INSERT INTO client_payment (amount, method, upi, user_id, project_id, status, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())";
                    st = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
                    st.setInt(1, amount);
                    st.setString(2, method);
                    st.setString(3, upi);
                    st.setInt(4, userId);
                    st.setInt(5, projectId);
                    st.setString(6, status);
                } else {
                    String query = "INSERT INTO client_payment (amount, method, cardholder_name, card_no, expiry, cvv, user_id, project_id, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                    st = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
                    st.setInt(1, amount);
                    st.setString(2, method);
                    st.setString(3, cardholderName);
                    st.setString(4, cardNo);
                    st.setString(5, expiry);
                    st.setString(6, cvv);
                    st.setInt(7, userId);
                    st.setInt(8, projectId);
                    st.setString(9, status);
                }

                int rowsInserted = st.executeUpdate();

                if (rowsInserted > 0) {
                    // Get generated payment_id for redirecting to bill.jsp
                    ResultSet generatedKeys = st.getGeneratedKeys();
                    int paymentId = 0;
                    if (generatedKeys.next()) {
                        paymentId = generatedKeys.getInt(1);
                    }

                    session.setAttribute("payment_success", true);

                    // Redirect to bill.jsp with paymentId param
                    pw.println("<script>alert('Payment successful!'); window.location.href='bill.jsp?paymentId=" + paymentId + "';</script>");
                } else {
                    session.setAttribute("payment_success", false);
                    pw.println("<script>alert('Payment failed. Try again later.'); window.location.href='payment.jsp';</script>");
                }

                con.close();
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("payment_success", false);
                pw.println("<script>alert('Server error occurred.'); window.location.href='payment.jsp';</script>");
            }
        } else {
            session.setAttribute("payment_success", false);
            pw.println("<script>alert('Payment validation failed. Please check your details.'); window.location.href='../client.jsp ';</script>");
        }
    }
}
