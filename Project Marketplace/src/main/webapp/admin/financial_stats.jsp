<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.*, java.util.*" %>
<%
    long totalRevenue = 0, monthlyRevenue = 0, pendingPayouts = 0, totalTransactions = 0;
    Map<String, Long> monthlyData = new LinkedHashMap<>();

    String[] months = new DateFormatSymbols().getShortMonths();
    List<String> last6Months = new ArrayList<>();

    Calendar cal = Calendar.getInstance();
    for (int i = 5; i >= 0; i--) {
        cal.setTime(new java.util.Date()
);
        cal.add(Calendar.MONTH, -i);
        String m = months[cal.get(Calendar.MONTH)];
        last6Months.add(m);
        monthlyData.put(m, 0L);
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/marketplace", "root", "root");

        PreparedStatement ps1 = con.prepareStatement("SELECT SUM(amount) FROM client_payment WHERE status='success'");
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) totalRevenue = rs1.getLong(1);

        PreparedStatement ps2 = con.prepareStatement("SELECT SUM(amount) FROM client_payment WHERE status='success' AND MONTH(created_at)=MONTH(CURDATE()) AND YEAR(created_at)=YEAR(CURDATE())");
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) monthlyRevenue = rs2.getLong(1);

      
        PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(*) FROM client_payment WHERE status='success'");
        ResultSet rs4 = ps4.executeQuery();
        if (rs4.next()) totalTransactions = rs4.getLong(1);

        PreparedStatement ps5 = con.prepareStatement("SELECT MONTH(created_at) AS m, SUM(amount) AS total FROM client_payment WHERE status='success' AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) GROUP BY MONTH(created_at)");
        ResultSet rs5 = ps5.executeQuery();
        while (rs5.next()) {
            int monthIndex = rs5.getInt("m");
            String m = months[monthIndex - 1];
            monthlyData.put(m, rs5.getLong("total"));
        }

        con.close();
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>DB Error: " + e.getMessage() + "</div>");
    }

    int goal = 100000; // Example monthly goal
    int goalPercent = (int)((monthlyRevenue * 100) / goal);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Financial Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/countup.js@2.0.7/dist/countUp.umd.js"></script>
  <style>
    body {
     background: #9796f0;  /* fallback for old browsers */
background: -webkit-linear-gradient(to right, #fbc7d4, #9796f0);  /* Chrome 10-25, Safari 5.1-6 */
background: linear-gradient(to right, #fbc7d4, #9796f0); /* W3C, IE 10+/ Edge, Firefox 16+, Chrome 26+, Opera 12+, Safari 7+ */
  
      font-family: 'Segoe UI', sans-serif;
      transition: background 0.5s ease;
    }
    .container { margin-top: 40px; }
    .card { margin-bottom: 20px; border-radius: 15px; }
    .toggle-dark { position: absolute; top: 20px; right: 20px; }
    .dark-mode {
      background: linear-gradient(to right, #232526, #414345);
      color: white;
    }
  </style>
</head>

<body>
<br>

<a href="../admin.jsp" class="btn btn-secondary" style="margin-left: 20px;">
  <i class="fas fa-arrow-left" style="font-size: 24px;"></i>
</a>
  <div class="container">
    <h2 class="mb-4">📊 Financial Dashboard</h2>

    <div class="row">
      <div class="col-md-3">
        <div class="card text-white bg-primary">
          <div class="card-body">
            <h5 class="card-title">Total Revenue</h5>
            <p class="fs-4">₹<span id="totalRevenue"><%= totalRevenue %></span></p>
          </div>
        </div>
      </div>

      <div class="col-md-3">
        <div class="card text-white bg-success">
          <div class="card-body">
            <h5 class="card-title">This Month</h5>
            <p class="fs-4">₹<span id="monthlyRevenue"><%= monthlyRevenue %></span></p>
            <div class="progress">
              <div class="progress-bar bg-warning" role="progressbar" style="width: <%= goalPercent %>%">
                <%= goalPercent %>% of ₹<%= goal %>
              </div>
            </div>
          </div>
        </div>
      </div>

      
      <div class="col-md-3">
        <div class="card text-white bg-dark">
          <div class="card-body">
            <h5 class="card-title">Total Transactions</h5>
            <p class="fs-4"><%= totalTransactions %> Deals</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Chart -->
    <div class="card">
      <div class="card-body">
        <h5 class="card-title">📈 Monthly Revenue Trend</h5>
        <canvas id="revenueChart" height="100"></canvas>
      </div>
    </div>
  </div>

  <script>
    const labels = [<% for (String m : last6Months) { %>'<%= m %>', <% } %>];
    const data = [<% for (String m : last6Months) { %><%= monthlyData.get(m) %>, <% } %>];

    const ctx = document.getElementById('revenueChart').getContext('2d');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Monthly Revenue (₹)',
          data: data,
          backgroundColor: 'rgba(54, 162, 235, 0.7)',
          borderColor: 'rgba(54, 162, 235, 1)',
          borderWidth: 1,
          borderRadius: 5
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });

    // Count Up Effect
    const totalRev = new countUp.CountUp('totalRevenue', <%= totalRevenue %>);
    const monthlyRev = new countUp.CountUp('monthlyRevenue', <%= monthlyRevenue %>);
    totalRev.start();
    monthlyRev.start();

    // Dark mode toggle
    function toggleDark() {
      document.body.classList.toggle("dark-mode");
    }
  </script>
</body>
</html>
