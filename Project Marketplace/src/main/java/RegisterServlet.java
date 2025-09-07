import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter pw = res.getWriter();

        String fullname = req.getParameter("fullname");
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phone_no = req.getParameter("phone_no");
        String address = req.getParameter("address");
        String role = req.getParameter("role");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

            String query = "INSERT INTO user(fullname, username, email, password, phone_no, address, role) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement st = con.prepareStatement(query);
            st.setString(1, fullname);
            st.setString(2, username);
            st.setString(3, email);
            st.setString(4, password);
            st.setString(5, phone_no);
            st.setString(6, address);
            st.setString(7, role);

            int result = st.executeUpdate();

            if (result > 0) {
                pw.println("<html><body>");
                pw.println("<script type='text/javascript'>");
                pw.println("alert('Register successfully!');");
                pw.println("window.location.href='login.html';");
                pw.println("</script>");
                pw.println("</body></html>");
            } else {
                pw.println("<html><body>");
                pw.println("<script type='text/javascript'>");
                pw.println("alert('Failed to register. Please try again.');");
                pw.println("window.location.href='login.html';");
                pw.println("</script>");
                pw.println("</body></html>");
            }

            st.close();
            con.close();

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            pw.println("<html><body>");
            pw.println("<h3>Error occurred: " + e.getMessage() + "</h3>");
            pw.println("</body></html>");
        }

        pw.close();
    }
}
