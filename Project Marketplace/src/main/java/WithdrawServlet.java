import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/developer/WithdrawServlet")
public class WithdrawServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("user_id");

        if (userId == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        int amount = Integer.parseInt(request.getParameter("amount"));
        String method = request.getParameter("method");

        // Handle both method fields
        String paypalEmail = method.equals("paypal") ? request.getParameter("paypal_email") : null;
        String accountNo = method.equals("bank") ? request.getParameter("account_no") : null;
        String ifsc = method.equals("bank") ? request.getParameter("ifsc") : null;
        String bankName = method.equals("bank") ? request.getParameter("bank_name") : null;

        String status = "Successful"; // Mark as successful if everything goes right

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

            String sql = "INSERT INTO withdraw_earning (user_id, amount, method, paypal_email, account_no, ifsc, bank_name, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, amount);
            ps.setString(3, method);
            ps.setString(4, paypalEmail);
            ps.setString(5, accountNo);
            ps.setString(6, ifsc);
            ps.setString(7, bankName);
            ps.setString(8, status);

            ps.executeUpdate();
            conn.close();

            session.setAttribute("withdrawSuccess", true);
            response.sendRedirect("withdraw.jsp");
session.setAttribute("status", status);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("withdraw.jsp");
        }
    }
}
