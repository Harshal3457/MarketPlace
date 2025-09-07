<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    HttpSession session1 = request.getSession(false);
    Integer userId = (Integer) session1.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Developer Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <style>
    body {
      background-image: linear-gradient(to top, #fbc2eb 0%, #a6c1ee 100%);
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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

    .dropdown-menu {
      right: 0;
      left: auto;
    }

    .profile-img {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      object-fit: cover;
      margin-right: 8px;
      border: 2px solid #fff;
      background-color: #ffffff;
      transition: transform 0.3s, box-shadow 0.3s;
    }

    .profile-wrapper:hover .profile-img {
      transform: scale(1.1);
      box-shadow: 0 0 10px rgba(255, 255, 255, 0.6);
    }

    .main-content {
      padding: 30px;
    }

    .card {
      transition: transform 0.3s;
      border: none;
      border-radius: 12px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
    }

    .card:hover {
      transform: translateY(-5px);
    }

    .dynamic-banner {
      width: 100%;
      height: 250px;
      margin-bottom: 30px;
    }

    .dynamic-banner img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      border-radius: 10px;
      box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
    }

    .section-title {
      font-size: 1.5rem;
      font-weight: bold;
      margin: 30px 0 15px;
      color: #343a40;
    }

    .navbar-brand {
      font-size: 30px;
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

<%
  String username = "";
  try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
         PreparedStatement st = con.prepareStatement("SELECT username FROM user WHERE user_id = ?")) {
        st.setInt(1, userId);
        try (ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                username = rs.getString("username");
            }
        }
    }
  } catch (Exception e) {
    out.println("<p class='text-danger'>Database error: " + e.getMessage() + "</p>");
  }
%>

    <div class="collapse navbar-collapse justify-content-end" id="navbarContent">
      <ul class="navbar-nav align-items-center">
        <li class="nav-item"><a class="nav-link" href="developer/upload_project.html">Upload Project</a></li>
        <li class="nav-item"><a class="nav-link" href="developer/project_sales.jsp">My Projects & Sales</a></li>
        <li class="nav-item"><a class="nav-link" href="developer/withdraw.jsp">Withdraw Earnings</a></li>
                <li class="nav-item"><a class="nav-link" href="developer/history.jsp">Withdraw history</a></li>
        
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle d-flex align-items-center profile-wrapper" href="#" role="button" data-bs-toggle="dropdown">
            <img src="https://ui-avatars.com/api/?name=<%= username %>&background=0D8ABC&color=fff" class="profile-img" alt="profile" />
            <span style="color:white;"><%= username %></span>
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item" href="developer/edit_profile.jsp">Edit Profile</a></li>
            <li><a class="dropdown-item" href="logout.jsp">Log Out</a></li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<!-- Main Content -->
<div class="main-content">
  <!-- Banner -->
  <div class="dynamic-banner">
    <img id="bannerImage" src="img/banner1.jpg" alt="Banner">
  </div>

<%
int totalProjects = 0;
int totalAmount = 0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root")) {

        PreparedStatement stmt1 = conn.prepareStatement("SELECT COUNT(*) FROM upload_project WHERE user_id = ?");
        stmt1.setInt(1, userId);
        ResultSet rs1 = stmt1.executeQuery();
        if (rs1.next()) {
            totalProjects = rs1.getInt(1);
        }
        rs1.close();
        stmt1.close();

        PreparedStatement stmt2 = conn.prepareStatement(
            "SELECT SUM(c.amount) FROM upload_project u JOIN client_payment c ON u.project_id = c.project_id WHERE u.user_id = ? AND c.status = 'success'");
        stmt2.setInt(1, userId);
        ResultSet rs2 = stmt2.executeQuery();
        if (rs2.next()) {
            totalAmount = rs2.getInt(1);
        }
        rs2.close();
        stmt2.close();

    }
} catch (Exception e) {
    e.printStackTrace();
}
%>

  <div class="row mb-4">
    <div class="col-md-4">
      <div class="card p-4 bg-primary text-white">
        <h5>Total Projects</h5>
        <h2><%= totalProjects %></h2>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card p-4 bg-success text-white">
        <h5>Total Sales</h5>
        <h2>₹<%= totalAmount %></h2>
      </div>
    </div>
    
  <% Integer availableBalance=(Integer) session.getAttribute("availableBalance"); %>  
    
    <div class="col-md-4">
      <div class="card p-4 bg-warning text-dark">
        <h5>Available Balance</h5>
        <h2>₹<%= availableBalance %></h2>
      </div>
    </div>
  </div>

<%
    class Project {
        String title, technology;
        int price;
        Project(String t, String tech, int p) {
            title = t; technology = tech; price = p;
        }
        public String getTitle() { return title; }
        public String getTechnology() { return technology; }
        public int getPrice() { return price; }
    }
    List<Project> projectList = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
             PreparedStatement stmt = conn.prepareStatement("SELECT title, technology, price FROM upload_project WHERE user_id = ?")) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                projectList.add(new Project(rs.getString("title"), rs.getString("technology"), rs.getInt("price")));
            }
            rs.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

  <div>
    <h3 class="section-title">Recent Projects</h3>
    <% for(Project p : projectList) { %>
      <div class="card p-3 mb-3">
        <h5><%= p.getTitle() %></h5>
        <p>Tech Stack: <%= p.getTechnology() %></p>
        <p>Price: <b>₹<%= p.getPrice() %></b></p>
      </div>
    <% } %>
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
  window.onload = () => {
    const bannerImages = ["img/banner1.jpg", "img/banner2.jpg", "img/banner3.jpg"];
    const bannerImage = document.getElementById("bannerImage");
    let currentIndex = 0;
    setInterval(() => {
      currentIndex = (currentIndex + 1) % bannerImages.length;
      bannerImage.src = bannerImages[currentIndex];
    }, 5000);
  };
</script>
</body>
</html>
