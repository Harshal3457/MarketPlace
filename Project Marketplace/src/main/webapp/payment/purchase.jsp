<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String projectId = request.getParameter("projectId");
  String title = request.getParameter("title");
  String price = request.getParameter("price");
  boolean paymentSuccess = false;
  if (session != null && session.getAttribute("payment_success") != null) {
      paymentSuccess = (Boolean) session.getAttribute("payment_success");
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Secure Online Payment</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background-color: #f5f5f5; }
    .payment-box {
      width: 600px; padding: 25px; background: #fff;
      border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .container-center {
      display: flex; justify-content: center; align-items: center; min-height: 100vh;
    }
    .btn-group {
      display: flex; gap: 15px; justify-content: center; margin-top: 20px;
    }
  </style>
</head>
<body>
<div class="container container-center">
  <div class="payment-box">
    <h4 class="text-center mb-4">Payment for: <%= title %></h4>

    <form id="paymentForm" onsubmit="handlePayment(event)" method="post" action="PaymentServlet">
      <div class="mb-3">
        <label class="form-label">Amount (INR)</label>
        <input type="number" class="form-control" id="paymentAmount" value="<%= price %>" name="amount" readonly>
      </div>
      <div class="mb-3">
        <label class="form-label">Select Payment Method</label>
        <select class="form-select" id="paymentMethod" name="method" onchange="switchPaymentMethod()" required>
          <option value="upi">UPI</option>
          <option value="debit">Debit Card</option>
        </select>
      </div>
      <div id="upiSection">
        <div class="mb-3">
          <label class="form-label">Your UPI ID</label>
          <input type="text" class="form-control" name="upi" placeholder="example@upi">
        </div>
      </div>
      <div id="cardSection" style="display: none;">
        <div class="mb-3"><label class="form-label">Cardholder Name</label><input type="text" class="form-control" name="cardholder_name"></div>
        <div class="mb-3"><label class="form-label">Card Number</label><input type="text" class="form-control" maxlength="16" name="card_no"></div>
        <div class="row">
          <div class="col-6 mb-3"><label class="form-label">Expiry</label><input type="text" class="form-control" name="expiry" placeholder="MM/YY"></div>
          <div class="col-6 mb-3"><label class="form-label">CVV</label><input type="password" class="form-control" maxlength="3" name="cvv"></div>
        </div>
      </div>
      <input type="hidden" name="projectId" value="<%= projectId %>">
      <input type="hidden" name="title" value="<%= title %>">

      <div class="btn-group">
        <button type="submit" class="btn btn-success w-50">Proceed to Pay</button>
        <a href="../client.jsp" class="btn btn-danger w-50">Cancel Payment</a>
      </div>
    </form>


    <% if (paymentSuccess) { %>
      <a href="bill.jsp"><button class="btn btn-warning w-100 mt-3">Generate Bill</button></a>
      <% session.removeAttribute("payment_success"); %>
    <% } %> 
 
  </div>
</div>

<script>
  function switchPaymentMethod() {
    const method = document.getElementById("paymentMethod").value;
    document.getElementById("upiSection").style.display = (method === "upi") ? "block" : "none";
    document.getElementById("cardSection").style.display = (method === "debit") ? "block" : "none";
  }

  function handlePayment(e) {
    e.preventDefault();
    alert("Processing Payment...");
    setTimeout(() => {
      document.getElementById("paymentForm").submit();
    }, 1500);
  }
</script>
</body>
</html>
