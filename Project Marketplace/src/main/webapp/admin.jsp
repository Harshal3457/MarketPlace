<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Admin Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      
      margin: 0;
      padding: 0;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      background: #d9a7c7;  /* fallback for old browsers */
background: -webkit-linear-gradient(to right, #fffcdc, #d9a7c7);  /* Chrome 10-25, Safari 5.1-6 */
background: linear-gradient(to right, #fffcdc, #d9a7c7); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
      
    }

    .navbar {
      background-color: #343a40;
    }

    .navbar-brand, .nav-link {
      color: white !important;
    }

    .nav-link.active {
      background-color: #007bff !important;
      font-weight: 600;
      border-radius: 5px;
    }

    .nav-link:hover {
      background-color: #495057 !important;
      color: #e0e0e0 !important;
    }

    .main-content {
      padding: 20px;
      flex: 1;
    }

    .card {
      margin-bottom: 20px;
      border: none;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
      transition: transform 0.3s;
    }

    .card:hover {
      transform: translateY(-5px);
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

    #loadingOverlay {
      position: fixed;
      top: 0;
      left: 0;
      height: 100vh;
      width: 100vw;
      background: rgba(255, 255, 255, 0.7);
      display: none;
      justify-content: center;
      align-items: center;
      font-size: 1.5rem;
      font-weight: 600;
      z-index: 9999;
    }

    #loadingOverlay .spinner-border {
      width: 3rem;
      height: 3rem;
      margin-right: 10px;
    }
    
    
    
    
  </style>
</head>

<body>

<!-- Loading Overlay -->
<div id="loadingOverlay">
  <div class="spinner-border text-primary" role="status"></div>
  Loading...
</div>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark sticky-top">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Marketplace</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item"><a class="nav-link active" href="admin.jsp"><i class="fas fa-users"></i> User Stats</a></li>
        <li class="nav-item"><a class="nav-link" href="admin/all_projects.jsp"><i class="fas fa-list"></i> All Projects</a></li>
        <li class="nav-item"><a class="nav-link" href="admin/manage_users.jsp"><i class="fas fa-user-cog"></i> Manage Users</a></li>
        <li class="nav-item"><a class="nav-link" href="admin/financial_stats.jsp"><i class="fas fa-chart-line"></i> Financial Stats</a></li>
        <li class="nav-item"><a class="nav-link" href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
      </ul>
    </div>
  </div>
</nav>

<%
int total_developer = 0;
int total_client = 0;
int totalAmount = 0;

Connection con = null;
PreparedStatement stmt = null, stmt1 = null, stmt2 = null;
ResultSet rs = null, rs1 = null, rs2 = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

    // Count developers
    stmt = con.prepareStatement("SELECT COUNT(user_id) FROM user WHERE role = ?");
    stmt.setString(1, "developer");
    rs = stmt.executeQuery();
    if (rs.next()) total_developer = rs.getInt(1);

    // Count clients
    stmt1 = con.prepareStatement("SELECT COUNT(user_id) FROM user WHERE role = ?");
    stmt1.setString(1, "client");
    rs1 = stmt1.executeQuery();
    if (rs1.next()) total_client = rs1.getInt(1);

    // Total sales (successful payments only)
    stmt2 = con.prepareStatement("SELECT amount, status FROM client_payment");
    rs2 = stmt2.executeQuery();
    while (rs2.next()) {
        if ("success".equalsIgnoreCase(rs2.getString("status"))) {
            totalAmount += rs2.getInt("amount");
        }
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (rs1 != null) rs1.close(); } catch (Exception e) {}
    try { if (rs2 != null) rs2.close(); } catch (Exception e) {}
    try { if (stmt != null) stmt.close(); } catch (Exception e) {}
    try { if (stmt1 != null) stmt1.close(); } catch (Exception e) {}
    try { if (stmt2 != null) stmt2.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

<!-- Main Content -->
<div class="main-content">
  <h2 class="mb-3">👋 Welcome Admin</h2>
  <p class="text-muted">Here’s a quick overview of your platform's performance.</p>
  <div class="row">
    <div class="col-md-4">
      <div class="card text-white bg-primary">
        <div class="card-body">
          <h5 class="card-title">Developers</h5>
          <p class="card-text fs-4"><%= total_developer %></p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card text-white bg-success">
        <div class="card-body">
          <h5 class="card-title">Clients</h5>
          <p class="card-text fs-4"><%= total_client %></p>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card text-white bg-warning">
        <div class="card-body">
          <h5 class="card-title">Total Sales</h5>
          <p class="card-text fs-4">₹ <%= totalAmount %></p>
        </div>
      </div>
    </div>
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
<script>
  const links = document.querySelectorAll('.nav-link');
  const loadingOverlay = document.getElementById('loadingOverlay');

  links.forEach(link => {
    link.addEventListener('click', function (e) {
      e.preventDefault();
      links.forEach(l => l.classList.remove('active'));
      this.classList.add('active');
      loadingOverlay.style.display = 'flex';
      setTimeout(() => {
        loadingOverlay.style.display = 'none';
        window.location.href = this.href;
      }, 1000);
    });
  });

  const currentPath = window.location.pathname.split('/').pop() || 'admin.jsp';
  links.forEach(link => {
    if (link.getAttribute('href').includes(currentPath)) {
      link.classList.add('active');
    }
  });
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
