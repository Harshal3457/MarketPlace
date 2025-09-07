<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page session="true" %>
<%
    HttpSession session1 = request.getSession(false);
    Integer userId = (Integer) session1.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Withdrawal History</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
     <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css">
    <style>
        body {
            background: linear-gradient(to right, #c6ffdd, #fbd786, #f7797d);
            font-family: 'Segoe UI', sans-serif;
        }
        .container {
            margin-top: 50px;
        }
        .status-badge {
            padding: 5px 10px;
            border-radius: 8px;
            color: white;
            font-size: 0.9rem;
        }
        .status-successful { background-color: #28a745; }
        .status-pending { background-color: #ffc107; color: #000; }
        .status-failed { background-color: #dc3545; }
    </style>
</head>
<body><br>
<br>
<a href="../developer.jsp" class="btn btn-secondary" style="margin-left: 20px;">
  <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
</a>

<div class="container">
    <h2 class="text-center mb-4">Withdrawal History</h2>
    <div class="card shadow">
        <div class="card-body">
            <table id="withdrawTable" class="table table-striped">
                <thead>
                    <tr>
                        <th>Sr No</th>
                        <th>Amount (₹)</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th>Requested On</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

                            ps = conn.prepareStatement("SELECT amount, method, status, created_at FROM withdraw_earning WHERE user_id = ? ORDER BY created_at DESC");
                            ps.setInt(1, userId);
                            rs = ps.executeQuery();

                            int srNo = 1;
                            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

                            while (rs.next()) {
                                int amount = rs.getInt("amount");
                                String method = rs.getString("method");
                                String status = rs.getString("status");
                                Timestamp date = rs.getTimestamp("created_at");

                                String badgeClass = "status-pending";
                                if ("Successful".equalsIgnoreCase(status)) badgeClass = "status-successful";
                                else if ("Failed".equalsIgnoreCase(status)) badgeClass = "status-failed";
                    %>
                        <tr>
                            <td><%= srNo++ %></td>
                            <td><%= amount %></td>
                            <td><%= method.substring(0, 1).toUpperCase() + method.substring(1) %></td>
                            <td><span class="status-badge <%= badgeClass %>"><%= status %></span></td>
                            <td><%= sdf.format(date) %></td>
                        </tr>
                    <% 
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' class='text-danger'>Database Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) rs.close();
                            if (ps != null) ps.close();
                            if (conn != null) conn.close();
                        }
                    %>
                </tbody>
            </table>
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
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
<script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
<script>
    $(document).ready(function () {
        $('#withdrawTable').DataTable({
            pageLength: 5,
            lengthChange: false,
            searching: true,
            ordering: true
        });
    });
</script>
</body>
</html>
