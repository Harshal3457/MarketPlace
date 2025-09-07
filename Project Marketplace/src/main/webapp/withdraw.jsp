<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*, java.util.*" %>
<%@ page session="true" %>

<%
    Integer balance = (Integer) session.getAttribute("availbalance");
    if (balance == null) {
        balance = 5000; // Default balance
        session.setAttribute("availbalance", balance);
    }

    String message = "";

    if (request.getParameter("withdraw") != null) {
        try {
            int withdrawAmount = Integer.parseInt(request.getParameter("amount"));
            String paypalId = request.getParameter("paypal");

            if (withdrawAmount <= 0) {
                message = "Please enter a valid withdrawal amount.";
            } else if (withdrawAmount > balance) {
                message = "Insufficient balance.";
            } else if (paypalId == null || paypalId.trim().isEmpty()) {
                message = "Please enter your PayPal ID.";
            } else {
                balance -= withdrawAmount;
                session.setAttribute("availbalance", balance);
                message = "₹" + withdrawAmount + " withdrawn successfully to PayPal ID: " + paypalId;
            }
        } catch (Exception e) {
            message = "Invalid input. Please enter numeric amount.";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Withdraw Money</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f0f2f5;
            display: flex;
            justify-content: center;
            padding-top: 50px;
        }
        .box {
            background: #fff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
            width: 350px;
        }
        h2 {
            margin-bottom: 20px;
        }
        input[type="text"], input[type="number"] {
            width: 100%;
            padding: 10px;
            margin-top: 8px;
            margin-bottom: 15px;
            border-radius: 8px;
            border: 1px solid #ccc;
        }
        button {
            background-color: #007bff;
            color: white;
            padding: 10px;
            border: none;
            width: 100%;
            border-radius: 8px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
        .message {
            margin-top: 15px;
            color: green;
        }
        .error {
            color: red;
        }
    </style>
</head>
<body>
    <div class="box">
        <h2>Withdraw Money</h2>
        <p><strong>Available Balance:</strong> ₹<%= balance %></p>
        <form method="post">
            <label>Enter Amount to Withdraw:</label>
            <input type="number" name="amount" required min="1">

            <label>Enter PayPal ID:</label>
            <input type="text" name="paypal" required>

            <button type="submit" name="withdraw">Withdraw</button>
        </form>

        <% if (!message.isEmpty()) { %>
            <p class="<%= message.contains("successfully") ? "message" : "error" %>"><%= message %></p>
        <% } %>
    </div>
</body>
</html>
