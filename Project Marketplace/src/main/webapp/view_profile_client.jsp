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
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(to right, #eaafc8, #654ea3);
    }
    .profile-container { max-width: 900px; margin: auto; background: white; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); padding: 25px; }
    .profile-header { display: flex; align-items: center; gap: 20px; }
    .profile-image-wrapper {
      position: relative;
      width: 80px;
      height: 80px;
      border-radius: 50%;
      border: 2px solid #ccc;
      overflow: hidden;
      background-color: #e9ecef;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .profile-image-wrapper img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      border-radius: 50%;
    }
    .section-title { margin-top: 30px; font-size: 1.25rem; border-bottom: 1px solid #ddd; padding-bottom: 5px; }
    .loading-spinner { display: none; text-align: center; margin-top: 50px; }
    .loading-spinner.active { display: block; }
    input[disabled] { background-color: #f1f1f1; }
    .navbar { background-color: #343a40; }
    .navbar-brand, .nav-link, .dropdown-toggle { color: white !important; }
    .navbar-nav .nav-item { margin-right: 20px; }
  </style>
</head>
<body>

<%
String fullname = "", email = "", username = "", phone_no = "", address = "", created_at = "N/A";
int totalPurchaseProject = 0;
int userId = (Integer) session.getAttribute("user_id");

// Update logic
if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("saveBtn") != null) {
    fullname = request.getParameter("fullname");
    email = request.getParameter("email");
    username = request.getParameter("username");
    phone_no = request.getParameter("phone_no");
    address = request.getParameter("address");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
        PreparedStatement updateSt = con.prepareStatement("UPDATE user SET fullname=?, email=?, username=?, phone_no=?, address=? WHERE user_id=?");
        updateSt.setString(1, fullname);
        updateSt.setString(2, email);
        updateSt.setString(3, username);
        updateSt.setString(4, phone_no);
        updateSt.setString(5, address);
        updateSt.setInt(6, userId);
        updateSt.executeUpdate();
        updateSt.close();
        con.close();
    } catch (Exception e) {
        out.println("<p class='text-danger'>Update Error: " + e.getMessage() + "</p>");
    }
}

// Fetch updated data
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

    PreparedStatement st = con.prepareStatement("SELECT fullname, email, username, phone_no, address, created_at FROM user WHERE user_id=?");
    st.setInt(1, userId);
    ResultSet rs = st.executeQuery();
    if (rs.next()) {
        fullname = rs.getString("fullname");
        email = rs.getString("email");
        username = rs.getString("username");
        phone_no = rs.getString("phone_no");
        address = rs.getString("address");
        created_at = rs.getString("created_at");
    }
    rs.close();
    st.close();

    PreparedStatement st2 = con.prepareStatement("SELECT COUNT(*) FROM client_payment WHERE user_id=? AND status='success'");
    st2.setInt(1, userId);
    ResultSet rs2 = st2.executeQuery();
    if (rs2.next()) totalPurchaseProject = rs2.getInt(1);
    rs2.close();
    st2.close();

    con.close();
} catch (Exception e) {
    out.println("<p style='color:red;'>Fetch Error: " + e.getMessage() + "</p>");
}
%>

<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Marketplace</a>
    <div class="collapse navbar-collapse" id="navbarContent">
      <ul class="navbar-nav ms-auto">
       
      </ul>
    </div>
  </div>
</nav>

<br><a href="client.jsp" class="btn btn-secondary ms-3"><i class="fas fa-arrow-left"></i> </a>

<div id="loader" class="loading-spinner">
  <div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div>
</div>

<div id="profileContent" class="profile-container d-none">
  <div class="profile-header">
    <div class="profile-image-wrapper">
      <img src="https://www.w3schools.com/w3images/avatar2.png" alt="Profile Picture">
    </div>
    <div class="profile-info">
      <h2><%= fullname %></h2>
      <p><%= email %></p>
    </div>
  </div>

  <div class="section-title">Account Info</div>
  <form id="editForm" method="post">
    <div class="mb-3"><label>Full Name</label><input type="text" class="form-control" name="fullname" value="<%= fullname %>" disabled></div>
    <div class="mb-3"><label>Username</label><input type="text" class="form-control" name="username" value="<%= username %>" disabled></div>
    <div class="mb-3"><label>Email</label><input type="text" class="form-control" name="email" value="<%= email %>" disabled></div>
    <div class="mb-3"><label>Phone Number</label><input type="text" class="form-control" name="phone_no" value="<%= phone_no %>" disabled></div>
    <div class="mb-3"><label>Address</label><input type="text" class="form-control" name="address" value="<%= address %>" disabled></div>

    <button type="button" class="btn btn-warning" onclick="enableEditing()">Edit</button>
    <button type="submit" class="btn btn-primary ms-2" id="saveBtn" disabled name="saveBtn">Save Changes</button>
  </form>

  <div class="section-title">Account Insights & Settings</div>
  <div class="row">
    <div class="col-md-6 mb-3"><label>Account Created On</label><input type="text" class="form-control" value="<%= created_at %>" disabled></div>
    <div class="col-md-6 mb-3"><label>Last Login</label><input type="text" class="form-control" value="May 30, 2025 at 2:45 PM" disabled></div>
    <div class="col-md-6 mb-3"><label>Total Projects Purchased</label><input type="text" class="form-control" value="<%= totalPurchaseProject %>" disabled></div>
    <div class="col-md-6 mb-3"><label>2-Step Verification</label><select class="form-select" disabled><option selected>Enabled</option><option>Disabled</option></select></div>
    <div class="col-12 mb-3"><label>Notification Preferences</label><select class="form-select" disabled><option selected>Receive all updates</option><option>Only important alerts</option><option>Do not disturb</option></select></div>
  </div>
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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function showProfile() {
    document.getElementById('loader').classList.add('active');
    setTimeout(() => {
      document.getElementById('loader').classList.remove('active');
      document.getElementById('profileContent').classList.remove('d-none');
    }, 1500);
  }

  function enableEditing() {
    const fields = document.querySelectorAll("#editForm input");
    fields.forEach(field => field.disabled = false);
    document.getElementById("saveBtn").disabled = false;
  }

  document.getElementById("editForm").addEventListener("submit", function (e) {
    const confirmUpdate = confirm("Do you want to update the data?");
    if (!confirmUpdate) {
      e.preventDefault();
    }
  });

  showProfile();
</script>
</body>
</html>
