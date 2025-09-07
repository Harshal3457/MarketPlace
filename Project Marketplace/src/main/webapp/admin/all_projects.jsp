<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    class Project {
        int project_id, price;
        String title, technology, categegory, status, fullname, date;

        Project(int project_id, String title, String technology, String categegory, String status, int price, String fullname, String date) {
            this.project_id = project_id;
            this.title = title;
            this.technology = technology;
            this.categegory = categegory;
            this.status = status;
            this.price = price;
            this.fullname = fullname;
            this.date = date;
        }
    }

    String action = request.getParameter("action");
    String idStr = request.getParameter("id");
    if (action != null && idStr != null) {
        int projectId = Integer.parseInt(idStr);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

            if ("approve".equals(action)) {
                PreparedStatement ps = conn.prepareStatement("UPDATE upload_project SET status='Approved' WHERE project_id=?");
                ps.setInt(1, projectId);
                ps.executeUpdate();
                ps.close();
            } else if ("reject".equals(action)) {
                PreparedStatement ps = conn.prepareStatement("UPDATE upload_project SET status='Pending' WHERE project_id=?");
                ps.setInt(1, projectId);
                ps.executeUpdate();
                ps.close();
            } else if ("remove".equals(action)) {
                PreparedStatement ps = conn.prepareStatement("DELETE FROM upload_project WHERE project_id=?");
                ps.setInt(1, projectId);
                ps.executeUpdate();
                ps.close();
            }

            conn.close();
        } catch (Exception e) {
            out.println("<p class='text-danger'>Action Error: " + e.getMessage() + "</p>");
        }
        response.sendRedirect("all_projects.jsp"); // Refresh page after action
        return;
    }

    List<Project> projectList = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

        String query = "SELECT up.project_id, up.title, up.technology, up.categegory, up.status, up.price, up.created_at, u.fullname " +
                       "FROM upload_project up JOIN user u ON up.user_id = u.user_id";
        PreparedStatement stmt = conn.prepareStatement(query);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            projectList.add(new Project(
                rs.getInt("project_id"),
                rs.getString("title"),
                rs.getString("technology"),
                rs.getString("categegory"),
                rs.getString("status"),
                rs.getInt("price"),
                rs.getString("fullname"),
                rs.getString("created_at")
            ));
        }

        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p class='text-danger'>Database error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>All Projects</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { 
   background: #9796f0;  /* fallback for old browsers */
background: -webkit-linear-gradient(to right, #fbc7d4, #9796f0);  /* Chrome 10-25, Safari 5.1-6 */
background: linear-gradient(to right, #fbc7d4, #9796f0); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
  
         display: flex;
  flex-direction: column;
  min-height: 100vh;
        }
        .badge-warning { background-color: #ffc107; }
        .badge-success { background-color: #28a745; }
        
        
   
    .navbar-brand{
    font-size:30px;
    }
    
     .navbar {
      background-color: #343a40;
    }

    .navbar-brand,
    .navbar-nav .nav-link,
    .dropdown-toggle {
      color: white !important;
    }

    .navbar-nav .nav-item {
      margin-right: 20px;
    }
     footer {
      background-color: #343a40;
      color: white;
      font-size: 14px;
      text-align: center;
      padding: 20px 0;
    }

    .footer-icons a {
      color: white;
      margin: 0 10px;
      text-decoration: none;
      font-size: 18px;
    }

    .footer-icons a:hover {
      color: #007bff;
    }
    
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Marketplace</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
      <span class="navbar-toggler-icon"></span>
    </button>



   
  </div>
</nav>

<div><br> 
<a href="../admin.jsp" class="btn btn-secondary" style="margin-left: 20px;">
  <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
</a></div>




<div class="container mt-5">
    <h2 class="mb-4">All Listed Projects</h2>
    <table class="table table-bordered table-hover align-middle">
        <thead class="table-dark">
        <tr>
            <th>Project ID</th>
            <th>Title</th>
            <th>Developer</th>
            <th>Category</th>
            <th>Status</th>
            <th>Price (INR)</th>
            <th>Date Listed</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <%
            for (Project p : projectList) {
        %>
        <tr>
            <td><%= String.format("%03d", p.project_id) %></td>
            <td><strong><%= p.title %></strong></td>
            <td><%= p.fullname %></td>
            <td><%= p.categegory %></td>
            <td>
                <span class="badge <%= "Approved".equalsIgnoreCase(p.status) ? "badge-success" : "badge-warning" %>">
                    <%= p.status %>
                </span>
            </td>
            <td>₹<%= p.price %></td>
            <td><%= p.date %></td>
            <td>
                <% if (!"Approved".equalsIgnoreCase(p.status)) { %>
                    <a href="?action=approve&id=<%= p.project_id %>" class="btn btn-success btn-sm">Approve</a>
                <% } else { %>
                    <a href="?action=reject&id=<%= p.project_id %>" class="btn btn-primary btn-sm">View</a>
                <% } %>
                <a href="?action=remove&id=<%= p.project_id %>" class="btn btn-danger btn-sm"
                   onclick="return confirm('Are you sure to remove this project?');">Remove</a>
            </td>
        </tr>
        <%
            }
        %>
        </tbody>
    </table>
</div>


<!-- Footer -->
<footer class="text-center text-white mt-5" style="background-color: #343a40;">
  <div class="container p-4">
    <section class="mb-4">
      <a class="btn btn-outline-light btn-floating m-1" href="#"><i class="fab fa-facebook-f"></i></a>
      <a class="btn btn-outline-light btn-floating m-1" href="#"><i class="fab fa-twitter"></i></a>
      <a class="btn btn-outline-light btn-floating m-1" href="#"><i class="fab fa-google"></i></a>
      <a class="btn btn-outline-light btn-floating m-1" href="https://www.instagram.com/vista.lens.07/profilecard/?igsh=NnBhOTJ1dWN4eXRx"><i class="fab fa-instagram"></i></a>
      <a class="btn btn-outline-light btn-floating m-1" href="https://www.linkedin.com/in/prathamesh-pawar-a55588276/?originalSubdomain=in"><i class="fab fa-linkedin-in"></i></a>
      <a class="btn btn-outline-light btn-floating m-1" href="https://github.com/pathu0707"><i class="fab fa-github"></i></a>
    </section>
  </div>
  <div class="text-center p-3" style="background-color: rgba(0,0,0,0.2); font-size: 14px;">
    © 2025 Project Marketplace | Developed with ❤️
  </div>
</footer>
</body>
</html>
