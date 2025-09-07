<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Contact Us - Project Marketplace</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet" />
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
    body {
      background-image: linear-gradient(120deg, #e0c3fc 0%, #8ec5fc 100%);
      color: #1e293b;
      line-height: 1.6;
    }
    header {
      background: #0f172a;
      color: #fff;
      padding: 20px 40px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .back-button {
      display: flex;
      align-items: center;
      text-decoration: none;
      color: white;
      font-size: 18px;
      transition: color 0.3s;
    }
    .back-button:hover { color: #71e9d1; }
    .material-symbols-outlined {
      font-size: 30px;
      margin-right: 8px;
      font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
    .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
    .info-box {
      background: #fff;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    form {
      background: #fff;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.05);
      margin-top: 30px;
    }
    form label {
      font-weight: 600;
      margin-bottom: 5px;
      display: block;
    }
    form input, form textarea {
      width: 100%;
      padding: 12px;
      margin-bottom: 20px;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      font-size: 16px;
    }
    form button {
      background: #2563eb;
      color: white;
      padding: 12px 20px;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
      transition: background 0.3s ease;
    }
    form button:hover { background: #1d4ed8; }
    footer {
      text-align: center;
      padding: 20px;
      background: #0f172a;
      color: #ccc;
      margin-top: 40px;
    }
  </style>
</head>
<body>

<header>
  <a href="home.jsp" class="back-button"><span class="material-symbols-outlined">arrow_back</span></a>
  <h1>Contact Project Marketplace</h1>
</header>

<div class="container">
  <!-- Contact Info Section -->
  <div class="info-box">
    <h3>Reach Out</h3>
    <p>Email: support@projectmarketplace.com</p>
    <p>Phone: +91 98765 43210</p>
  </div>

  <!-- Form Submission Logic -->
  <%
    String messageStatus = "";
    if (request.getMethod().equalsIgnoreCase("POST")) {
      String fullname = request.getParameter("fullname");
      String email = request.getParameter("email");
      String subject = request.getParameter("subject");
      String message = request.getParameter("message");

      try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");
          String sql = "INSERT INTO message (fullname, email, subject, message) VALUES (?, ?, ?, ?)";
          PreparedStatement ps = con.prepareStatement(sql);
          ps.setString(1, fullname);
          ps.setString(2, email);
          ps.setString(3, subject);
          ps.setString(4, message);

          int rows = ps.executeUpdate();
          if (rows > 0) {
              messageStatus = "success";
          } else {
              messageStatus = "failed";
          }
          ps.close();
          con.close();
      } catch (Exception e) {
          messageStatus = "error: " + e.getMessage();
      }
    }
  %>

  <!-- Contact Form -->
  <form method="post" action="">
    <h2 style="margin-bottom: 20px;">Send Us a Message</h2>

    <label for="name">Full Name</label>
    <input type="text" id="name" name="fullname" required>

    <label for="email">Email Address</label>
    <input type="email" id="email" name="email" required>

    <label for="subject">Subject</label>
    <input type="text" id="subject" name="subject" required>

    <label for="message">Message</label>
    <textarea id="message" name="message" rows="5" required></textarea>

    <button type="submit">Submit</button>
  </form>

  <!-- Feedback Script -->
  <% if ("success".equals(messageStatus)) { %>
    <script>alert("Message sent successfully!"); window.location.href = "home.html";</script>
  <% } else if ("failed".equals(messageStatus)) { %>
    <script>alert("Message not sent. Please try again.");</script>
  <% } else if (messageStatus.startsWith("error:")) { %>
    <script>alert("Error: <%= messageStatus.substring(6) %>");</script>
  <% } %>
</div>

<footer>
  © 2025 Project MarketPlace | Developed with ❤️
</footer>

</body>
</html>
