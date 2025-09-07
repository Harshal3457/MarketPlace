<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Client Profile</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(to right, #eaafc8, #654ea3); }
    .profile-container { max-width: 900px; margin: auto; background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); padding: 25px; }
    .profile-header { display: flex; align-items: center; gap: 20px; }
    .profile-image-wrapper {
      position: relative; width: 80px; height: 80px; border-radius: 50%; border: 2px solid #ccc;
      overflow: hidden; background-color: #e9ecef; display: flex; align-items: center; justify-content: center;
    }
    .profile-image-wrapper img {
      width: 100%; height: 100%; object-fit: cover; display: block; border-radius: 50%;
    }
    .section-title { margin-top: 30px; font-size: 1.25rem; border-bottom: 1px solid #ddd; padding-bottom: 5px; }
    input[disabled] { background-color: #f1f1f1; }
    .navbar { background-color: #343a40; }
    .navbar-brand, .nav-link, .dropdown-toggle { color: white !important; }
    .navbar-nav .nav-item { margin-right: 20px; }
  </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Marketplace</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarContent">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
            <i class="fas fa-user"></i> Account
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item" href="client_profile.jsp">View Profile</a></li>
            <li><a class="dropdown-item" href="logout.jsp">Logout</a></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<br>
<a href="../developer.jsp" class="btn btn-secondary ms-3"><i class="fas fa-arrow-left"></i> </a>

<%
String fullname = "", email = "", username = "", phone_no = "", address = "", github = "", skill = "";
int userId = (Integer) session.getAttribute("user_id");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
    PreparedStatement st = con.prepareStatement("SELECT fullname, email, username, phone_no, address, github, skill FROM user WHERE user_id=?");
    st.setInt(1, userId);
    ResultSet rs = st.executeQuery();
    if (rs.next()) {
        fullname = rs.getString("fullname");
        email = rs.getString("email");
        username = rs.getString("username");
        phone_no = rs.getString("phone_no");
        address = rs.getString("address");
        github = rs.getString("github");
        skill = rs.getString("skill");
    }
    rs.close(); st.close(); con.close();
} catch (Exception e) {
    out.println("<p class='text-danger'>Database error: " + e.getMessage() + "</p>");
}
%>

<div class="profile-container">
  <div class="profile-header">
    <div class="profile-image-wrapper">
      <img src="https://www.w3schools.com/w3images/avatar2.png" alt="Profile Picture">
    </div>
    <div>
      <h2><%= fullname %></h2>
      <p><%= email %></p>
    </div>
  </div>

  <div class="section-title">Account Info</div>
  <form method="post">
    <div class="mb-3"><label>Full Name</label><input type="text" class="form-control" name="fullname" value="<%= fullname %>" disabled></div>
    <div class="mb-3"><label>Username</label><input type="text" class="form-control" name="username" value="<%= username %>" disabled></div>
    <div class="mb-3"><label>Email</label><input type="text" class="form-control" name="email" value="<%= email %>" disabled></div>
    <div class="mb-3"><label>Phone Number</label><input type="text" class="form-control" name="phone_no" value="<%= phone_no %>" disabled></div>
    <div class="mb-3"><label>Address</label><input type="text" class="form-control" name="address" value="<%= address %>" disabled></div>
    <div class="mb-3"><label>GitHub</label><input type="text" class="form-control" name="github" value="<%= github %>" disabled></div>
    <div class="mb-3"><label>Skill</label><input type="text" class="form-control" name="skill" value="<%= skill %>" disabled></div>
    <button type="button" class="btn btn-warning" onclick="enableEditing()">Edit</button>
    <button type="submit" class="btn btn-primary ms-2" id="saveBtn" disabled name="saveBtn">Save Changes</button>
  </form>

  <%
    if (request.getParameter("saveBtn") != null) {
        String fn = request.getParameter("fullname");
        String em = request.getParameter("email");
        String un = request.getParameter("username");
        String ph = request.getParameter("phone_no");
        String ad = request.getParameter("address");
        String gh = request.getParameter("github");
        String sk = request.getParameter("skill");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
            PreparedStatement st = con.prepareStatement("UPDATE user SET fullname=?, email=?, username=?, phone_no=?, address=?, github=?, skill=? WHERE user_id=?");
            st.setString(1, fn);
            st.setString(2, em);
            st.setString(3, un);
            st.setString(4, ph);
            st.setString(5, ad);
            st.setString(6, gh);
            st.setString(7, sk);
            st.setInt(8, userId);
            int updated = st.executeUpdate();
            if (updated > 0) {
                out.println("<script>alert('Profile updated successfully!'); location.href='client_profile.jsp';</script>");
            }
            st.close(); con.close();
        } catch (Exception e) {
            out.println("<p class='text-danger'>Update Error: " + e.getMessage() + "</p>");
        }
    }
  %>
<%
String created_at = "N/A";
int totalUploadProject = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

    PreparedStatement st = con.prepareStatement("SELECT created_at FROM user WHERE user_id=?");
    st.setInt(1, (Integer) session.getAttribute("user_id"));
    ResultSet rs = st.executeQuery();
    if (rs.next()) created_at = rs.getString("created_at");
    rs.close();
    st.close();

    PreparedStatement st2 = con.prepareStatement("SELECT COUNT(*) FROM upload_project WHERE user_id=? AND status='approved'");
    st2.setInt(1, (Integer) session.getAttribute("user_id"));
    ResultSet rs2 = st2.executeQuery();
    if (rs2.next()) totalUploadProject = rs2.getInt(1);
    rs2.close();
    st2.close();
    con.close();
} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
}
%>

  <div class="section-title">Account Insights & Settings</div>
  <div class="row">
    <div class="col-md-6 mb-3"><label>Account Created On</label><input type="text" class="form-control" value="<%= created_at %>" disabled></div>
    <div class="col-md-6 mb-3"><label>Last Login</label><input type="text" class="form-control" value="May 30, 2025 at 2:45 PM" disabled></div>
    <div class="col-md-6 mb-3"><label>Total Projects Uploaded</label><input type="text" class="form-control" value="<%= totalUploadProject %>" disabled></div>
    <div class="col-md-6 mb-3"><label>2-Step Verification</label><select class="form-select" disabled><option selected>Enabled</option><option>Disabled</option></select></div>
    <div class="col-12 mb-3"><label>Notification Preferences</label><select class="form-select" disabled><option selected>Receive all updates</option><option>Only important alerts</option><option>Do not disturb</option></select></div>
  </div>
</div>

<script>
  function enableEditing() {
    document.querySelectorAll("form input").forEach(input => input.disabled = false);
    document.getElementById("saveBtn").disabled = false;
  }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
