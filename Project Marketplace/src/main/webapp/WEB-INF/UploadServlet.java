import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/UploadServlet")
@MultipartConfig(maxFileSize = 1024 * 1024 * 10) // 10MB limit
public class UploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/html");
        PrintWriter pw = res.getWriter();

        String title = req.getParameter("title");
        String desc = req.getParameter("desc");
        String tech = req.getParameter("tech");
        String tags = req.getParameter("tags");
        String categ = req.getParameter("categ");
        int price = Integer.parseInt(req.getParameter("price"));
        String git = req.getParameter("git");

        Part filePart = req.getPart("file");
        InputStream fileContent = filePart.getInputStream(); // Binary stream for blob

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

            String query = "INSERT INTO projects (title, description, technology, tags, category, price, file, github_link) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement st = con.prepareStatement(query);
            st.setString(1, title);
            st.setString(2, desc);
            st.setString(3, tech);
            st.setString(4, tags);
            st.setString(5, categ);
            st.setInt(6, price);
            st.setBlob(7, fileContent); // Store the file as BLOB
            st.setString(8, git);

            int result = st.executeUpdate();
            if (result > 0) {
                pw.println("Project uploaded successfully.");
            } else {
                pw.println("Upload failed.");
            }

        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace(pw);
        }
    }
}
