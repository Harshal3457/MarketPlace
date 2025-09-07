<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Purchase History</title>

  <!-- Bootstrap & FontAwesome CDN -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>

  <style>
    body {
    background: #654ea3;  /* fallback for old browsers */
background: -webkit-linear-gradient(to right, #eaafc8, #654ea3);  /* Chrome 10-25, Safari 5.1-6 */
background: linear-gradient(to right, #eaafc8, #654ea3); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
      font-family: 'Segoe UI', sans-serif;
    }

    .history-container {
      max-width: 1000px;
      margin: 40px auto;
      background: white;
      padding: 30px;
      border-radius: 15px;
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
    }

    .page-title {
      font-size: 28px;
      font-weight: bold;
      margin-bottom: 20px;
    }

    .table thead {
      background-color: #343a40;
      color: white;
    }

    .loading {
      text-align: center;
      margin-top: 80px;
    }

    .loading .spinner-border {
      width: 3rem;
      height: 3rem;
    }

    #sortSelect {
      font-size: 16px;
    }

    .search-sort-wrapper {
      margin-bottom: 20px;
    }
    
    .btn-back {
      margin: 20px;
    }
    
  </style>
</head>
<body>


<a href="client.jsp" class="btn btn-secondary btn-back">
  <i class="fas fa-arrow-left"></i> 
</a>


<div class="container history-container">
  <div class="page-title"><i class="fas fa-history me-2"></i> Purchase History</div>

  <!-- 🔁 Search & Sort Row -->
  <div class="row search-sort-wrapper">
    <div class="col-md-8 mb-2 mb-md-0">
      <input type="text" class="form-control" id="searchBox" placeholder="Search by Project Name...">
    </div>
    <div class="col-md-4">
      <select id="sortSelect" class="form-select">
        <option value="newest">Sort: Newest First</option>
        <option value="oldest">Sort: Oldest First</option>
      </select>
    </div>
  </div>

  <!-- Loader -->
  <div id="loader" class="loading">
    <div class="spinner-border text-primary" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>
  </div>

  <!-- Table Section -->
  <div id="purchaseTable" style="display: none;">
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th>#</th>
          <th>Project Name</th>
          <th>Amount</th>
          <th>Date</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody id="purchaseBody">
        <%
          int index = 1;
          String username = (String) session.getAttribute("username");
          if (username != null) {
            try {
              Class.forName("com.mysql.cj.jdbc.Driver");
              Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
              PreparedStatement stmt = conn.prepareStatement(
                "SELECT up.title, cp.amount, cp.created_at, cp.status " +
                "FROM client_payment cp " +
                "JOIN upload_project up ON cp.project_id = up.project_id " +
                "JOIN user u ON cp.user_id = u.user_id " +
                "WHERE u.username = ?"
              );
              stmt.setString(1, username);
              ResultSet rs = stmt.executeQuery();
              while (rs.next()) {
                String title = rs.getString("title");
                int amount = rs.getInt("amount");
                String createdAt = rs.getString("created_at");
                String status = rs.getString("status");
        %>
        <tr>
          <td><%= index++ %></td>
          <td><%= title %></td>
          <td>₹<%= amount %></td>
          <td><%= createdAt %></td>
          <td><span class="badge bg-<%= status.equalsIgnoreCase("success") ? "success" : "danger" %> text-white"><%= status %></span></td>
        </tr>
        <%
              }
              rs.close();
              stmt.close();
              conn.close();
            } catch (Exception e) {
              out.println("<tr><td colspan='5'><span class='text-danger'>Database Error: " + e.getMessage() + "</span></td></tr>");
            }
          } else {
            out.println("<tr><td colspan='5'><span class='text-warning'>You must be logged in to view purchase history.</span></td></tr>");
          }
        %>
      </tbody>
    </table>
  </div>
</div>

<script>
  // Simulate loading
  window.onload = function () {
    setTimeout(() => {
      document.getElementById('loader').style.display = 'none';
      document.getElementById('purchaseTable').style.display = 'block';
    }, 1200);
  };

  // Live search
  document.getElementById("searchBox").addEventListener("input", function () {
    const search = this.value.toLowerCase();
    const rows = document.querySelectorAll("#purchaseBody tr");
    rows.forEach(row => {
      const project = row.children[1].innerText.toLowerCase();
      row.style.display = project.includes(search) ? "" : "none";
    });
  });

  // Sort by date
  document.getElementById("sortSelect").addEventListener("change", function () {
    const rows = Array.from(document.querySelectorAll("#purchaseBody tr"));
    const sortType = this.value;

    rows.sort((a, b) => {
      const dateA = new Date(a.children[3].innerText);
      const dateB = new Date(b.children[3].innerText);
      return sortType === "newest" ? dateB - dateA : dateA - dateB;
    });

    const tbody = document.getElementById("purchaseBody");
    tbody.innerHTML = "";
    rows.forEach(row => tbody.appendChild(row));
  });
</script>

</body>
</html>
