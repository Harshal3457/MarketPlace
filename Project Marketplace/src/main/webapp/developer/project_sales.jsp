<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Developer Dashboard - Projects & Sales</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    body {
      background-image: linear-gradient(to top, #fbc2eb 0%, #a6c1ee 100%);
      font-family: 'Segoe UI', sans-serif;
    }

    .container {
      max-width: 1000px;
      margin: 40px auto;
    }

    .section-title {
      margin-top: 40px;
      margin-bottom: 20px;
      font-size: 24px;
      font-weight: bold;
    }

    .project-card {
      padding: 15px;
      background: #fff;
      border: 1px solid #ccc;
      border-radius: 8px;
      margin-bottom: 15px;
    }

    .badge-status {
      font-size: 0.9rem;
    }

    .btn-back {
      margin: 20px;
    }

    footer {
      background-color: #343a40;
      color: white;
      padding: 15px;
      text-align: center;
      margin-top: 50px;
    }
  </style>
</head>

<body>
<%
    HttpSession session1 = request.getSession(false);
    Integer userId = (session1 != null) ? (Integer) session1.getAttribute("user_id") : null;
%>

<a href="../developer.jsp" class="btn btn-secondary btn-back">
  <i class="fas fa-arrow-left"></i> 
</a>

<div class="container">

  <!-- Section 1: Uploaded Projects -->
  <h2 class="section-title"><i class="fas fa-upload me-2"></i>Uploaded Projects</h2>

  <%
    if (userId != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
            PreparedStatement ps1 = conn.prepareStatement("SELECT status,title, technology, price FROM upload_project WHERE user_id = ?");
            ps1.setInt(1, userId);
            ResultSet rs1 = ps1.executeQuery();

            while (rs1.next()) {
            	String status=rs1.getString("status");
                String title = rs1.getString("title");
                String tech = rs1.getString("technology");
                int price = rs1.getInt("price");
                
  %>
              <div class="project-card">
                <h5><%= title %></h5>
                <p>Technology: <%= tech %></p>
                <p>Price: ₹ <%= price %></p>
               <hr> 
               
    <%           if("approved".equals(status)){ %>
                         <p> Status:
  <span style="display: inline-block; background-color: #28a745; color: white; padding: 5px 12px; border-radius: 6px; font-weight: bold;">
    <%= status %>
  </span>
</p>
         <%} else {%>     
               
             <p> Status:
  <span style="display: inline-block; background-color: red; color: white; padding: 5px 12px; border-radius: 6px; font-weight: bold;">
    <%= status %>
  </span>
</p>
<%} %>
              </div>
  <%
            }

            rs1.close();
            ps1.close();
            conn.close();
        } catch (Exception e) {
            out.println("<p class='text-danger'>Error: " + e.getMessage() + "</p>");
        }
    } else {
        out.println("<p class='text-danger'>Please login to view your data.</p>");
    }
  %>

  <!-- Section 2: Sales Summary -->
  <h2 class="section-title"><i class="fas fa-chart-line me-2"></i>Sales Summary</h2>

  <div class="table-responsive">
    <table class="table table-bordered">
      <thead class="table-dark">
        <tr>
          <th>Date</th>
          <th>Project</th>
          <th>Client</th>
          <th>Amount</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
      <%
        int totalAmount = 0;
        if (userId != null) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

                PreparedStatement ps2 = con.prepareStatement(
                    "SELECT cp.created_at, up.title, u.fullname, cp.amount, cp.status " +
                    "FROM client_payment cp " +
                    "JOIN upload_project up ON cp.project_id = up.project_id " +
                    "JOIN user u ON cp.user_id = u.user_id " +
                    "WHERE up.user_id = ?"
                );
                ps2.setInt(1, userId);
                ResultSet rs2 = ps2.executeQuery();

                while (rs2.next()) {
                    String date = rs2.getString("created_at");
                    String project = rs2.getString("title");
                    String client = rs2.getString("fullname");
                    int amount = rs2.getInt("amount");
                    String status = rs2.getString("status");

                    if ("success".equalsIgnoreCase(status)) {
                        totalAmount += amount;
                    }
      %>
                    <tr>
                      <td><%= date %></td>
                      <td><%= project %></td>
                      <td><%= client %></td>
                      <td>₹<%= amount %></td>
                      <td>
                        <% if ("success".equalsIgnoreCase(status)) { %>
                          <span class="badge bg-success badge-status"><%= status %></span>
                        <% } else if ("pending".equalsIgnoreCase(status)) { %>
                          <span class="badge bg-warning text-dark badge-status"><%= status %></span>
                        <% } else { %>
                          <span class="badge bg-danger badge-status"><%= status %></span>
                        <% } %>
                      </td>
                    </tr>
      <%
                }

                session.setAttribute("totalAmount", totalAmount);

                rs2.close();
                ps2.close();
                con.close();
            } catch (Exception e) {
                out.println("<tr><td colspan='5' class='text-danger'>Error loading sales data: " + e.getMessage() + "</td></tr>");
            }
        }
      %>
      </tbody>
    </table>
  </div>

  <!-- Total Amount Section -->
  <div class="mt-4">
    <h4>Total Successful Payment Amount:<b> ₹ <%= totalAmount %></b></h4>
  </div>

</div>

<!-- Footer -->
<footer>
  &copy; 2025 Project Marketplace. All rights reserved.
</footer>

</body>
</html>
