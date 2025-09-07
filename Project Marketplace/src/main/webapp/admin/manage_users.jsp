<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
class User {
    int user_id;
    String username, email, role, status, created_at;

    User(int user_id, String username, String email, String role, String status, String created_at) {
        this.user_id = user_id;
        this.username = username;
        this.email = email;
        this.role = role;
        this.status = status;
        this.created_at = created_at;
    }
}

String action = request.getParameter("action");
String idStr = request.getParameter("id");

if (action != null && idStr != null) {
    int user_id = Integer.parseInt(idStr);
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

        if ("ban".equalsIgnoreCase(action)) {
            PreparedStatement ps = con.prepareStatement("UPDATE user SET status='banned' WHERE user_id=?");
            ps.setInt(1, user_id);
            ps.executeUpdate();
            ps.close();
        } else if ("unban".equalsIgnoreCase(action)) {
            PreparedStatement ps = con.prepareStatement("UPDATE user SET status='active' WHERE user_id=?");
            ps.setInt(1, user_id);
            ps.executeUpdate();
            ps.close();
        } else if ("delete".equalsIgnoreCase(action)) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM user WHERE user_id=?");
            ps.setInt(1, user_id);
            ps.executeUpdate();
            ps.close();
        }
        con.close();
    } catch (Exception e) {
        out.println("<p class='text-danger'>Action Error: " + e.getMessage() + "</p>");
    }
    response.sendRedirect("manage_users.jsp"); // Redirect to refresh data
    return;
}

List<User> userList = new ArrayList<>();
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

    PreparedStatement st = conn.prepareStatement("SELECT user_id, username, email, role, status, created_at FROM user");
    ResultSet rs = st.executeQuery();
    while (rs.next()) {
        userList.add(new User(
            rs.getInt("user_id"),
            rs.getString("username"),
            rs.getString("email"),
            rs.getString("role"),
            rs.getString("status"),
            rs.getString("created_at")
        ));
    }
    rs.close();
    st.close();
    conn.close();
} catch (Exception e) {
    out.println("<p class='text-danger'>Database error: " + e.getMessage() + "</p>");
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Manage Users</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    body {
     background: #9796f0;  /* fallback for old browsers */
background: -webkit-linear-gradient(to right, #fbc7d4, #9796f0);  /* Chrome 10-25, Safari 5.1-6 */
background: linear-gradient(to right, #fbc7d4, #9796f0); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */

      font-family: Arial, sans-serif;
    }
    .container {
      margin-top: 40px;
    }
    .actions .btn {
      margin-right: 5px;
    }
    .badge-success { background-color: #28a745; }
    .badge-danger { background-color: #dc3545; }
  </style>
</head>
<body>
<br>
<a href="../admin.jsp" class="btn btn-secondary" style="margin-left: 20px;">
  <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
</a>
<div class="container">
  <h2 class="mb-4 text-center">User Management Dashboard</h2>
  <table class="table table-bordered table-hover">
    <thead class="table-dark">
      <tr>
        <th>ID</th>
        <th>Username</th>
        <th>Email</th>
        <th>Role</th>
        <th>Status</th>
        <th>Created At</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% for (User user : userList) { %>
        <tr>
          <td><%= user.user_id %></td>
          <td><%= user.username %></td>
          <td><%= user.email %></td>
          <td><%= user.role %></td>
          <td>
            <span class="badge <%= user.status.equalsIgnoreCase("active") ? "bg-success" : "bg-danger" %>">
              <%= user.status.substring(0, 1).toUpperCase() + user.status.substring(1).toLowerCase() %>
            </span>
          </td>
          <td><%= user.created_at %></td>
          <td class="actions">
            <% if ("active".equalsIgnoreCase(user.status)) { %>
              <a href="manage_users.jsp?action=ban&id=<%= user.user_id %>" class="btn btn-warning btn-sm">
                <i class="fas fa-user-slash"></i> Ban
              </a>
            <% } else { %>
              <a href="manage_users.jsp?action=unban&id=<%= user.user_id %>" class="btn btn-success btn-sm">
                <i class="fas fa-user-check"></i> Unban
              </a>
            <% } %>
            <a href="manage_users.jsp?action=delete&id=<%= user.user_id %>" 
               class="btn btn-danger btn-sm"
               onclick="return confirm('Are you sure you want to delete this user?');">
              <i class="fas fa-trash-alt"></i> Delete
            </a>
          </td>
        </tr>
      <% } %>
    </tbody>
  </table>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
