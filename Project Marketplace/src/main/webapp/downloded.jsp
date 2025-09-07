<%@ page import="java.sql.*, java.io.*" %>
<%@ page session="true" contentType="text/html; charset=UTF-8" %>

<%
    HttpSession session1 = request.getSession(false);
    if (session1 == null || session1.getAttribute("user_id") == null) {
        response.sendRedirect("client_login.jsp");
        return;
    }

    int userId = (Integer) session1.getAttribute("user_id");
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Downloaded Projects</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f4f6f8;
            padding: 40px;
        }
        .container {
            max-width: 1000px;
            margin: auto;
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 5px 18px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
        .card {
            background: #fdfdfd;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .project-info {
            max-width: 70%;
        }
        .project-info h4 {
            margin: 0;
            color: #333;
        }
        .project-info p {
            margin: 5px 0;
            color: #555;
        }
        .btn-view {
            padding: 10px 18px;
            background: #28a745;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-size: 15px;
            transition: 0.3s ease;
        }
        .btn-view:hover {
            background: #218838;
        }
        .no-projects {
            text-align: center;
            font-size: 18px;
            color: #777;
            margin-top: 40px;
        }
        
         .btn-back {
      margin: 20px;
    }
    
    </style>
</head>
<body>
<a href="client.jsp" class="btn btn-secondary" style="margin-left: 20px;">
  <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
</a>

<div class="container">
    <h2><i class="fas fa-folder-open"></i> Your Downloaded Projects</h2>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

        String query = "SELECT cp.payment_id, cp.amount, up.title " +
                       "FROM client_payment cp " +
                       "JOIN upload_project up ON cp.project_id = up.project_id " +
                       "WHERE cp.user_id = ? AND cp.status = 'success'";

        ps = con.prepareStatement(query);
        ps.setInt(1, userId);
        rs = ps.executeQuery();

        boolean hasProjects = false;

        while (rs.next()) {
            hasProjects = true;
            String title = rs.getString("title");
            String paymentId = rs.getString("payment_id");
            String amount = rs.getString("amount");
%>
        <div class="card">
            <div class="project-info">
                <h4><i class="fas fa-file-archive"></i> <%= title %></h4>
                <p>Amount Paid: ₹<%= amount %></p>
            </div>
            <a href="payment/download.jsp?action=view&paymentId=<%= paymentId %>" class="btn-view"><i class="fas fa-eye"></i> View</a>
        </div>
<%
        }

        if (!hasProjects) {
%>
        <p class="no-projects">😕 You haven't downloaded any projects yet.</p>
<%
        }

    } catch (Exception e) {
        out.println("<p class='no-projects'>⚠ Error loading projects: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (con != null) con.close(); } catch (Exception e) {}
    }
%>

</div>
</body>
</html>
