<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
  String username = (String) session.getAttribute("username");
  if (username == null) {
    response.sendRedirect("login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Client Marketplace</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

  <style>
    html, body { height: 100%; margin: 0; }
    body { display: flex; flex-direction: column; background: #654ea3;  /* fallback for old browsers */
background: -webkit-linear-gradient(to right, #eaafc8, #654ea3);  /* Chrome 10-25, Safari 5.1-6 */
background: linear-gradient(to right, #eaafc8, #654ea3); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
 }
    .content-wrapper { flex: 1; }
    .navbar { background-color: #343a40; }
    .navbar-brand, .navbar-nav .nav-link, .dropdown-toggle { color: white !important; }
    .navbar-nav .nav-item { margin-right: 20px; }
    .dropdown-menu { right: 0; left: auto; }
    .profile-img {
      width: 40px; height: 40px; border-radius: 50%;
      object-fit: cover; margin-right: 8px; border: 2px solid #fff;
      background-color: #ffffff; transition: transform 0.3s, box-shadow 0.3s;
    }
    .profile-wrapper:hover .profile-img {
      transform: scale(1.1); box-shadow: 0 0 10px rgba(255, 255, 255, 0.6);
    }
    .project-card {
      border: 1px solid #dee2e6; border-radius: 8px; padding: 15px;
      background: white; margin-bottom: 20px;
      transition: box-shadow 0.3s ease;
    }
    .project-card:hover { box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); }
    .price-tag { font-weight: 600; font-size: 1.1rem; color: #198754; }
    
    .item{
    color:white;
    font-size:18px;
    margin-right:25px;
    text-decoration: none;
    }
  </style>
</head>
<body>

<div class="content-wrapper">
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark px-4 py-2 mb-4">
    <div class="container-fluid">
      <a class="navbar-brand" href="index.html">Marketplace</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse justify-content-end" id="navbarContent">
        <ul class="navbar-nav align-items-center">
        <li><a class="item" href="downloded.jsp">🛒 Downloaded Project</a></li>
          <li><a class="item" href="purchase_history.jsp">🛒 Purchase History</a></li>
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle d-flex align-items-center profile-wrapper" href="#" id="profileDropdown"
               role="button" data-bs-toggle="dropdown" aria-expanded="false">
              <img src="https://ui-avatars.com/api/?name=<%= username %>&background=0D8ABC&color=fff" class="profile-img" alt="profile" />
              <span><%= username %></span>
            </a>
            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="profileDropdown">
              <li><a class="dropdown-item" href="view_profile_client.jsp">✏️ Edit Profile</a></li>
            
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item text-danger" href="logout.jsp">🚪 Log Out</a></li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- Filters -->
  <div class="container mb-4">
    <div class="row">
      <div class="col-md-4">
        <select id="categoryFilter" class="form-select">
          <option value="">All Categories</option>
          <option value="Web App">Web App</option>
          <option value="Mobile App">Mobile App</option>
          <option value="Desktop App">Desktop App</option>
          <option value="Library">Library</option>
        </select>
      </div>
      <div class="col-md-4">
        <select id="techFilter" class="form-select">
          <option value="">All Tech Stacks</option>
          <option value="Java">Java</option>
          <option value="Python">Python</option>
          <option value="JavaScript">JavaScript</option>
          <option value="React">React</option>
          <option value="Spring Boot">Spring Boot</option>
          <option value="Flutter">Flutter</option>
        </select>
      </div>
      <div class="col-md-4">
        <input id="searchInput" type="search" class="form-control" placeholder="Search projects..." />
      </div>
    </div>
  </div>

  <!-- Project Cards -->
  <div class="container">
    <div class="row" id="projectsContainer">

      <%
        class Project {
          int id, price;
          String title, technology, category, fullname, status;
          Project(String status, int id, String title, String technology, String category, int price, String fullname) {
            this.status = status;
            this.id = id;
            this.title = title;
            this.technology = technology;
            this.category = category;
            this.price = price;
            this.fullname = fullname;
          }
        }

        List<Project> projectList = new ArrayList<>();
        try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
          PreparedStatement stmt = conn.prepareStatement("SELECT up.status, up.project_id, up.title, up.technology, up.categegory, up.price, u.fullname FROM upload_project up JOIN user u ON up.user_id = u.user_id");
          ResultSet rs = stmt.executeQuery();
          while (rs.next()) {
            projectList.add(new Project(
              rs.getString("status"),
              rs.getInt("project_id"),
              rs.getString("title"),
              rs.getString("technology"),
              rs.getString("categegory"),
              rs.getInt("price"),
              rs.getString("fullname")
            ));
          }
          rs.close(); stmt.close(); conn.close();
        } catch (Exception e) {
          out.println("<p class='text-danger'>Database error: " + e.getMessage() + "</p>");
        }

        for (Project p : projectList) {
          if ("approved".equalsIgnoreCase(p.status)) {
      %>
      <div class="col-md-4">
        <div class="project-card" data-category="<%=p.category.toLowerCase()%>" data-tech="<%=p.technology.toLowerCase()%>" data-title="<%=p.title.toLowerCase()%>">
          <h5><%=p.title%></h5>
          <p>Technology:
            <% for (String tech : p.technology.split(",")) { %>
              <span class="badge bg-info text-dark"><%= tech.trim() %></span>
            <% } %>
          </p>
          <p>Category: <%=p.category%></p>
          <p>Developed By: <b><%= p.fullname %></b></p>
          <p class="price-tag">₹<%=p.price%></p>
         <%
  boolean alreadyPurchased = false;
  try {
    Connection conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
    PreparedStatement checkPurchase = conn2.prepareStatement("SELECT * FROM client_payment pp JOIN user u ON pp.user_id = u.user_id WHERE u.username = ? AND pp.project_id = ?");
    checkPurchase.setString(1, username);
    checkPurchase.setInt(2, p.id);
    ResultSet purchaseResult = checkPurchase.executeQuery();
    if (purchaseResult.next()) {
      alreadyPurchased = true;
    }
    purchaseResult.close();
    checkPurchase.close();
    conn2.close();
  } catch (Exception e) {
    out.println("<p class='text-danger'>Error checking purchase status: " + e.getMessage() + "</p>");
  }

  if (!alreadyPurchased) {
%>
<a href="payment/purchase.jsp?projectId=<%=p.id%>&title=<%=p.title%>&price=<%=p.price%>">
  <button class="btn btn-success btn-sm">Purchase</button>
</a>
<%
  } else {
%>
<span class="badge bg-success">✔ Purchased</span>
<%
  }
%>

        </div>
      </div>
      <% } } %>

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

<!-- Filtering Script -->
<script>
  function filterProjects() {
    const category = document.getElementById('categoryFilter').value.toLowerCase();
    const tech = document.getElementById('techFilter').value.toLowerCase();
    const search = document.getElementById('searchInput').value.toLowerCase();
    const cards = document.querySelectorAll('.project-card');
    cards.forEach(card => {
      const matchesCategory = category === '' || card.dataset.category.includes(category);
      const matchesTech = tech === '' || card.dataset.tech.includes(tech);
      const matchesSearch = card.dataset.title.includes(search);
      card.parentElement.style.display = (matchesCategory && matchesTech && matchesSearch) ? 'block' : 'none';
    });
  }
  document.getElementById('categoryFilter').addEventListener('change', filterProjects);
  document.getElementById('techFilter').addEventListener('change', filterProjects);
  document.getElementById('searchInput').addEventListener('input', filterProjects);
</script>

</body>
</html>
