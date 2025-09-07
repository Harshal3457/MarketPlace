<%@ page import="java.sql.*, java.io.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String paymentId = request.getParameter("paymentId");
    boolean showPage = true;

    // Default values
    String projectName = "N/A";
    String clientName = "N/A";
    String amount = "0.00";
    String status = "failed";
    boolean isPaymentSuccess = false;

    byte[] fileBytes = null;
    String fileName = "project.zip";

    if (paymentId == null || paymentId.trim().isEmpty()) {
        response.sendRedirect("client.jsp");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

        PreparedStatement ps = con.prepareStatement(
            "SELECT up.title, up.file, cp.amount, cp.status, u.fullname " +
            "FROM client_payment cp " +
            "JOIN upload_project up ON cp.project_id = up.project_id " +
            "JOIN user u ON cp.user_id = u.user_id " +
            "WHERE cp.payment_id = ?"
        );
        ps.setString(1, paymentId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            projectName = rs.getString("title");
            amount = rs.getString("amount");
            status = rs.getString("status");
            clientName = rs.getString("fullname");
            InputStream input = rs.getBinaryStream("file");

            if (input != null) {
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                byte[] temp = new byte[4096];
                int bytesRead;
                while ((bytesRead = input.read(temp)) != -1) {
                    buffer.write(temp, 0, bytesRead);
                }
                fileBytes = buffer.toByteArray();
                fileName = projectName.replaceAll("\\s+", "_") + ".zip";
            }

            isPaymentSuccess = "success".equalsIgnoreCase(status);
        }

        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Handle download
   String action = request.getParameter("action");

if ((action != null && (action.equals("download") || action.equals("view"))) && fileBytes != null && isPaymentSuccess) {
    response.setContentType("application/zip");

    if (action.equals("download")) {
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
    } else {
        response.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
    }

    response.setContentLength(fileBytes.length);
    ServletOutputStream outStream = response.getOutputStream();
    outStream.write(fileBytes);
    outStream.flush();
    outStream.close();
    showPage = false;
}

%>

<% if (showPage) { %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Download Project</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f4f4f4;
            padding: 40px;
        }
        .container {
            max-width: 700px;
            margin: auto;
            background: #fff;
            padding: 35px;
            border-radius: 15px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #222;
            margin-bottom: 30px;
        }
        .project-info p {
            font-size: 18px;
            margin: 10px 0;
            color: #444;
        }
        .btn-download {
            display: inline-block;
            background: #007BFF;
            color: #fff;
            padding: 14px 30px;
            border: none;
            border-radius: 8px;
            font-size: 17px;
            text-decoration: none;
            cursor: pointer;
            transition: 0.3s ease;
        }
        .btn-download:hover {
            background: #0056b3;
        }
        .message {
            text-align: center;
            margin-top: 20px;
            color: red;
            font-size: 17px;
            font-weight: bold;
        }
        .status-success { color: green; }
        .status-failed { color: red; }
        .back-btn {
            display: inline-block;
            background-color: #6c757d;
            color: white;
            padding: 12px 25px;
            font-size: 16px;
            border-radius: 8px;
            text-decoration: none;
            transition: background-color 0.3s ease;
        }
        .back-btn:hover {
            background-color: #5a6268;
        }
        .center { text-align: center; }
    </style>
</head>
<body>

<div class="container">
    <h2><i class="fas fa-file-archive"></i> Project Download</h2>

    <div class="project-info">
        <p><strong>Client Name:</strong> <%= clientName %></p>
        <p><strong>Project Name:</strong> <%= projectName %></p>
        <p><strong>Amount Paid:</strong> ₹<%= amount %></p>
        <p><strong>Status:</strong>
            <span class="<%= isPaymentSuccess ? "status-success" : "status-failed" %>">
                <%= isPaymentSuccess ? "Payment Successful ✅" : "Payment Failed ❌" %>
            </span>
        </p>
    </div>

    <div class="center">
        <% if (isPaymentSuccess && fileBytes != null) { %>
            <form method="post">
                <input type="hidden" name="paymentId" value="<%= paymentId %>">
                <input type="hidden" name="action" value="download">
                <button type="submit" class="btn-download">
                    <i class="fas fa-download"></i> Download ZIP File
                </button>
            </form>
        <% } else if (isPaymentSuccess && fileBytes == null) { %>
            <p class="message">✅ Payment done, but project file not found in database!</p>
        <% } else { %>
            <p class="message">❌ You must complete the payment to download the project file.</p>
        <% } %>

        <br><br>
        <a href="../client.jsp" class="back-btn">Return to Dashboard</a>
    </div>
</div>

</body>
</html>
<% } %>
