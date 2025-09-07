<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    HttpSession session1 = request.getSession(false);
    Integer userId = (Integer) session1.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    int totalEarning = 0, totalWithdrawn = 0;
    Boolean withdrawSuccess = (Boolean) session1.getAttribute("withdrawSuccess");
    session1.removeAttribute("withdrawSuccess");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

        PreparedStatement ps1 = conn.prepareStatement("SELECT IFNULL(SUM(c.amount), 0) FROM upload_project u JOIN client_payment c ON u.project_id = c.project_id WHERE u.user_id = ?");
        ps1.setInt(1, userId);
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) totalEarning = rs1.getInt(1);

        PreparedStatement ps2 = conn.prepareStatement("SELECT IFNULL(SUM(amount), 0) FROM withdraw_earning WHERE user_id = ? AND status = 'Successful'");
        ps2.setInt(1, userId);
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) totalWithdrawn = rs2.getInt(1);

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }

    int availableBalance = totalEarning - totalWithdrawn;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Withdraw Earnings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            background: linear-gradient(to right, #c6ffdd, #fbd786, #f7797d);
            font-family: 'Segoe UI', sans-serif;
        }
        .container-box {
            max-width: 700px;
            background: white;
            margin: 40px auto;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 0 15px rgba(0,0,0,0.15);
        }
        .info-box {
            background: #f8f9fa;
            border-left: 5px solid #0d6efd;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
        }
        #paypalFields, #bankFields { display: none; }
    </style>
</head>
<body>

<% if (withdrawSuccess != null) { %>
    <script>
        Swal.fire({
            icon: '<%= withdrawSuccess ? "success" : "error" %>',
            title: '<%= withdrawSuccess ? "Withdrawal Successful" : "Withdrawal Failed" %>',
            text: '<%= withdrawSuccess ? "Your withdrawal was processed successfully." : "Insufficient balance. Withdrawal failed." %>',
            confirmButtonColor: '#0d6efd'
        });
    </script>
<% } %>

<div class="container-box">
    <h2 class="text-center mb-4"><i class="fas fa-wallet"></i> Withdraw Earnings</h2>

    <div class="info-box">
        <p><strong>Total Earnings:</strong> ₹<%= totalEarning %></p>
        <p><strong>Total Withdrawn:</strong> ₹<%= totalWithdrawn %></p>
        <p><strong>Available Balance After Withdrawal:</strong> ₹<span id="availableBalance"><%= availableBalance %></span></p>
        <% session.setAttribute("availableBalance", availableBalance); %>
    </div>

    <form action="WithdrawServlet" method="post" id="withdrawForm">
        <input type="hidden" id="availableHidden" value="<%= availableBalance %>">

        <div class="mb-3">
            <label class="form-label">Amount to Withdraw</label>
            <input type="number" name="amount" id="withdrawAmount" class="form-control" min="100" max="<%= availableBalance %>" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Withdrawal Method</label>
            <select name="method" class="form-select" id="methodSelect" required>
                <option value="">--Select--</option>
                <option value="paypal">PayPal</option>
                <option value="bank">Bank Transfer</option>
            </select>
        </div>

        <div id="paypalFields">
            <div class="mb-3">
                <label class="form-label">PayPal Email</label>
                <input type="email" name="paypal_email" class="form-control">
            </div>
        </div>

        <div id="bankFields">
            <div class="mb-3">
                <label class="form-label">Account Number</label>
                <input type="text" name="account_no" class="form-control">
            </div>
            <div class="mb-3">
                <label class="form-label">IFSC Code</label>
                <input type="text" name="ifsc" class="form-control">
            </div>
            <div class="mb-3">
                <label class="form-label">Bank Name</label>
                <input type="text" name="bank_name" class="form-control">
            </div>
        </div>

        <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary w-100"><i class="fas fa-paper-plane"></i> Submit Withdrawal</button>
            <a href="../developer.jsp" class="btn btn-secondary w-100"><i class="fas fa-times"></i> Cancel</a>
        </div>
    </form>
</div>

<script>
    const methodSelect = document.getElementById("methodSelect");
    const paypalFields = document.getElementById("paypalFields");
    const bankFields = document.getElementById("bankFields");
    const withdrawAmount = document.getElementById("withdrawAmount");
    const availableBalance = parseInt(document.getElementById("availableHidden").value);
    const availableBalanceDisplay = document.getElementById("availableBalance");

    methodSelect.addEventListener("change", () => {
        paypalFields.style.display = methodSelect.value === "paypal" ? "block" : "none";
        bankFields.style.display = methodSelect.value === "bank" ? "block" : "none";
    });

    withdrawAmount.addEventListener("input", () => {
        const val = parseInt(withdrawAmount.value);
        if (!isNaN(val) && val >= 0 && val <= availableBalance) {
            availableBalanceDisplay.innerText = availableBalance - val;
        } else {
            availableBalanceDisplay.innerText = availableBalance;
        }
    });

    document.getElementById("withdrawForm").addEventListener("submit", function (e) {
        e.preventDefault();
        Swal.fire({
            title: 'Confirm Withdrawal',
            text: "Submit your withdrawal request?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#0d6efd',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, submit'
        }).then((result) => {
            if (result.isConfirmed) {
                this.submit();
            }
        });
    });
</script>

</body>
</html>
