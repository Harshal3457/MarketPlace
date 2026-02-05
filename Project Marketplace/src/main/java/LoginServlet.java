import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/marketplace";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "root";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("text/html");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Basic validation
        if (username == null || password == null ||
            username.isEmpty() || password.isEmpty()) {
            res.getWriter().println("Username and Password required!");
            return;
        }

        // 🔐 Admin login (avoid hardcoding in real apps)
        if ("admin0707".equals(username) && "admin123".equals(password)) {
            createSession(req, username, "admin", 0);
            res.sendRedirect("admin.jsp");
            return;
        }

        String query = "SELECT user_id, password, role, status FROM users WHERE username=?";

        try (
            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            PreparedStatement st = con.prepareStatement(query)
        ) {
            Class.forName("com.mysql.cj.jdbc.Driver");

            st.setString(1, username);
            ResultSet rs = st.executeQuery();

            if (rs.next()) {

                String dbPassword = rs.getString("password");
                String role = rs.getString("role");
                String status = rs.getString("status");
                int userId = rs.getInt("user_id");

                // ✅ Password check
                if (!password.equals(dbPassword)) {
                    res.getWriter().println("Invalid password!");
                    return;
                }

                // ✅ Status check
                if (!"active".equalsIgnoreCase(status)) {
                    res.getWriter().println("Account is inactive!");
                    return;
                }

                // ✅ Session creation
                createSession(req, username, role, userId);

                // ✅ Role based redirect
                switch (role.toLowerCase()) {
                    case "client":
                        res.sendRedirect("client.jsp");
                        break;
                    case "developer":
                        res.sendRedirect("developer.jsp");
                        break;
                    default:
                        res.getWriter().println("Unknown role!");
                }

            } else {
                res.getWriter().println("User not found!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().println("Server Error. Please try again later.");
        }
    }

    // 🔐 Centralized session handling
    private void createSession(HttpServletRequest req, String username, String role, int userId) {
        HttpSession oldSession = req.getSession(false);
        if (oldSession != null) oldSession.invalidate();

        HttpSession newSession = req.getSession(true);
        newSession.setAttribute("username", username);
        newSession.setAttribute("role", role);
        newSession.setAttribute("user_id", userId);
        newSession.setMaxInactiveInterval(15 * 60); // 15 mins
    }
}
