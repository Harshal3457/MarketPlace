import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/developer/UploadServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 10)  // 10 MB limit
public class UploadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter pw = res.getWriter();

        HttpSession session = req.getSession(false);
        Integer userId = (Integer) session.getAttribute("user_id");

        if (userId == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String technology = req.getParameter("technology");
        String tags = req.getParameter("tags");
        String category = req.getParameter("categegory");  // intentionally kept as categegory
        String giturl = req.getParameter("giturl");

        Part filePart = req.getPart("file");
        InputStream fileContent = null;
        if (filePart != null) {
            fileContent = filePart.getInputStream();
        }

        int price = 0;
        try {
            price = Integer.parseInt(req.getParameter("price"));
        } catch (NumberFormatException e) {
            pw.println("Invalid price format. Please enter a valid number.");
            return;
        }

        try {
            // Database connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/marketplace", "root", "root");

            // SQL insert statement
            String query = "INSERT INTO upload_project (title, description, technology, tags, categegory, price, file, giturl, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement st = con.prepareStatement(query);
            st.setString(1, title);
            st.setString(2, description);
            st.setString(3, technology);
            st.setString(4, tags);
            st.setString(5, category);  // using categegory column name
            st.setInt(6, price);
            st.setBlob(7, fileContent);
            st.setString(8, giturl);
            st.setInt(9, userId);

            int result = st.executeUpdate();
            if (result > 0) {
                pw.println("<script type='text/javascript'>");
                pw.println("alert('Project uploaded successfully!');");
                pw.println("window.location.href='upload_project.html';");
                pw.println("</script>");
            } else {
                pw.println("<script type='text/javascript'>");
                pw.println("alert('Failed to upload project. Please try again.');");
                pw.println("window.location.href='upload_project.html';");
                pw.println("</script>");
            }


            st.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace(pw);
        }
    }
}