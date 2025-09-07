
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.invalidate(); // destroy user session
    response.sendRedirect("login.html"); // redirect to login page
%>
