<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Get and validate payment ID from request
    String paymentIdParam = request.getParameter("paymentId");
    int paymentId = 0;
    if (paymentIdParam != null && !paymentIdParam.isEmpty()) {
        try {
            paymentId = Integer.parseInt(paymentIdParam);
        } catch (NumberFormatException e) {
            paymentId = 0; // Will trigger "Invalid Payment ID" message later
        }
    }

    class Project {
        String title, fullname, method, created_at;
        int price, payment_id;

        Project(String title, String fullname, String method, String created_at, int price, int payment_id) {
            this.title = title;
            this.fullname = fullname;
            this.method = method;
            this.created_at = created_at;
            this.price = price;
            this.payment_id = payment_id;
        }
    }

    Project project = null;

    if (paymentId > 0) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

            String query = "SELECT up.title, up.price, u.fullname, cp.payment_id, cp.created_at, cp.method " +
                           "FROM upload_project up " +
                           "JOIN user u ON up.user_id = u.user_id " +
                           "JOIN client_payment cp ON up.project_id = cp.project_id " +
                           "WHERE cp.payment_id = ?";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, paymentId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                project = new Project(
                    rs.getString("title"),
                    rs.getString("fullname"),
                    rs.getString("method"),
                    rs.getString("created_at"),
                    rs.getInt("price"),
                    rs.getInt("payment_id")
                );
            }

            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
            out.println("<p class='text-danger'>Database error: " + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Receipt</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f9ff;
            font-family: 'Segoe UI', sans-serif;
            padding: 40px 20px;
        }
        .receipt {
            background-color: #ffffff;
            border-radius: 10px;
            padding: 30px;
            max-width: 700px;
            margin: auto;
            box-shadow: 0 8px 24px rgba(0,0,0,0.1);
        }
        .receipt-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .receipt-header h2 {
            color: #28a745;
        }
        .receipt-table td {
            padding: 8px 0;
        }
        .footer-note {
            font-size: 0.9rem;
            color: #777;
        }
    </style>
</head>
<body>

<div class="receipt">
    <div class="receipt-header">
        <div>
            <h2>Payment Receipt</h2>
            <p class="text-muted">Project Marketplace</p>
        </div>
        <div>
            <img src="https://img.icons8.com/color/48/000000/receipt-approved.png" alt="Receipt Icon">
        </div>
    </div>
    <hr>

    <% if (project != null) { %>
        <table class="table table-borderless receipt-table">
            <tr><td><strong>Project Name:</strong></td><td><%= project.title %></td></tr>
            <tr><td><strong>Client Name:</strong></td><td><%= project.fullname %></td></tr>
            <tr><td><strong>Amount Paid:</strong></td><td>₹ <%= project.price %></td></tr>
            <tr><td><strong>Payment ID:</strong></td><td><%= project.payment_id %></td></tr>
            <tr><td><strong>Payment Method:</strong></td><td><%= project.method %></td></tr>
            <tr><td><strong>Payment Date:</strong></td><td><%= project.created_at %></td></tr>
        </table>
        <hr>
        <p class="text-center text-success">Thank you for your payment!</p>
        <p class="text-center footer-note">For any issues, contact us at <a href="mailto:support@projectportal.com">support@projectportal.com</a>.</p>
        <div class="text-center mt-4">
            <a href="../client.jsp" class="btn btn-primary me-2">Return to Dashboard</a>
            <a href="download.jsp?paymentId=<%= project.payment_id %>" class="btn btn-success">Download Project</a>
        </div>
    <% } else { %>
        <p class="text-center text-danger">No record found. Please check your Payment ID or contact support.</p>
        <div class="text-center mt-3">
            <a href="../client.jsp" class="btn btn-secondary">Back to Dashboard</a>
        </div>
    <% } %>
</div>

</body>
</html>
