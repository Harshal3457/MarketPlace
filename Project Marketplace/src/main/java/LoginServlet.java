import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        PrintWriter pw = res.getWriter();
        res.setContentType("text/html");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try {
            // Admin login logic first
            if ("admin0707".equals(username) && "admin123".equals(password)) {
                HttpSession session = req.getSession();
                session.setAttribute("username", username);
                session.setAttribute("role", "admin");
                res.sendRedirect("admin.jsp");
                return;
            }

            // Regular user login logic
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

            String query = "SELECT status, user_id, password, role FROM user WHERE username=?";
            PreparedStatement st = con.prepareStatement(query);
            st.setString(1, username);
            ResultSet rs = st.executeQuery();

            if (rs.next()) {
                String status = rs.getString("status");
                String storedPassword = rs.getString("password");
                String role = rs.getString("role");
                int userId = rs.getInt("user_id");

                if (password.equals(storedPassword) && "active".equals(status)) {
                    HttpSession session = req.getSession();
                    session.setAttribute("username", username);
                    session.setAttribute("role", role);
                    session.setAttribute("user_id", userId);

                    if ("client".equals(role)) {
                        res.sendRedirect("client.jsp");
                    } else if ("developer".equals(role)) {
                        res.sendRedirect("developer.jsp");
                    } else {
                        pw.println("Invalid role or redirect not defined.");
                    }
                } else {
                    pw.println("Invalid password or inactive user.");
                }
            } else {
                pw.println("User not found");
            }

            rs.close();
            st.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().println("Error: " + e.getMessage());
        }
    }
}
