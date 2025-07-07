<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%@ page import="java.util.List, java.util.ArrayList" %>
<%@ page import="com.auction.vo.MemberDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 로그인된 사용자 정보 가져오기
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/member/luxury-login.jsp");
        return;
    }

 // 사용자가 입력한 관심 상품 이름 받기
    String itemName = request.getParameter("itemName");

    // 세션에서 관심 상품 목록 가져오기
    List<String> interestItems = (List<String>) session.getAttribute("interestItems");
    
    // 처음이라면 새로운 리스트 생성
    if (interestItems == null) {
        interestItems = new ArrayList<>();
    }
    
    // 관심 상품 목록에 새로운 상품 추가
    interestItems.add(itemName);
    
    // 세션에 관심 상품 목록 저장
    session.setAttribute("interestItems", interestItems);

    // 등록 후 interestPage.jsp로 리다이렉트
    response.sendRedirect("interestPage.jsp");
%>
