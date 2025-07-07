<%-- 
  File: WebContent/product/productDetail.jsp
  역할: 즉시 구매 기능이 포함된 최종 버전의 상품 상세 페이지
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<%@ page import="com.auction.vo.MemberDTO, com.auction.vo.ProductDTO,
                 com.auction.dao.ProductDAO,
                 java.sql.Connection,
                 java.text.SimpleDateFormat,
                 java.text.DecimalFormat,
                 static com.auction.common.JDBCTemplate.*" %>
<%
    String ctx = request.getContextPath();
    MemberDTO loginUser = (MemberDTO)session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(ctx + "/member/loginForm.jsp");
        return;
    }

    // productId 파싱 및 DTO 조회
    int productId = 0;
    if (request.getParameter("productId") != null)
        productId = Integer.parseInt(request.getParameter("productId"));

    ProductDTO p = null;
    if (productId > 0) {
        Connection conn = getConnection();
        p = new ProductDAO().selectProductById(conn, productId);
        close(conn);
    }

    // 상태 플래그
    boolean isEnded    = p != null && new java.util.Date().after(p.getEndTime());
    boolean isSeller   = p != null && loginUser.getMemberId().equals(p.getSellerId());
    boolean isWinner   = p != null && p.getWinnerId()!=null && loginUser.getMemberId().equals(p.getWinnerId());

    // 포맷터 준비
    DecimalFormat    df  = new DecimalFormat("###,###,###");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy년 MM월 dd일 HH:mm");
    int currentPrice = (p!=null) 
        ? (p.getCurrentPrice()==0 ? p.getStartPrice() : p.getCurrentPrice()) 
        : 0;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Art Auction - 작품 상세</title>

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">

  <!-- 전역 스타일 -->
  <link rel="stylesheet" href="<%= ctx %>/resources/css/luxury-global-style.css">
  <link rel="stylesheet" href="<%= ctx %>/resources/css/layout.css">

  <!-- Font Awesome -->
  <link
    rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    integrity="sha512-p1CmX1YlR1X+VHN/99qzygrhcQ+AyxDJF9+u6EQZK8tkg8n4hqqy5p1eXH/Z5W7wGMtpY+Oc4+w0wXK4mvx1eg=="
    crossorigin="anonymous"
    referrerpolicy="no-referrer"
  />

  <style>
    /* 배경 전체 어두운 톤 유지 */
    body {
      margin: 0;
      background-color: #1a1a1a;
      color: #e0e0e0;
      font-family: 'Noto Sans KR', sans-serif;
    }

    /* 상세 페이지만 중앙에 띄우기 */
    .detail-main {
      display: flex;
      justify-content: center;
      padding: 60px 20px;
    }
    .detail-container {
      display: flex;
      gap: 40px;
      max-width: 1200px;
      width: 100%;
      background-color: #2b2b2b;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 8px 20px rgba(0,0,0,0.5);
    }

    /* 좌측 이미지 */
    .product-image-section {
      flex: 1;
    }
    .product-image-section img {
      width: 100%;
      height: auto;
      display: block;
    }

    /* 우측 정보 */
    .product-details-section {
      flex: 1;
      padding: 40px;
      display: flex;
      flex-direction: column;
    }
    .product-details-section .artist-name {
      font-size: 18px;
      color: #aaa;
    }
    .product-details-section .product-title {
      font-family: 'Playfair Display', serif;
      font-size: 36px;
      color: #fff;
      margin: 10px 0 30px;
    }
    .product-details-section .description {
      flex-grow: 1;
      line-height: 1.8;
      color: #ddd;
      margin-bottom: 30px;
    }

    /* 가격 정보 및 버튼 */
    .price-info {
      background-color: rgba(0,0,0,0.3);
      padding: 20px;
      border-radius: 8px;
    }
    .price-info .label {
      font-size: 14px;
      color: #aaa;
    }
    .price-info .price {
      font-size: 28px;
      font-weight: bold;
      color: #d4af37;
      margin: 5px 0 0;
    }
    .bid-actions { margin-top: 30px; }
    .bid-input-group {
      display: flex;
      gap: 10px;
      margin-top: 10px;
    }
    .bid-input-group input {
      flex: 1;
      padding: 12px;
      font-size: 16px;
      background-color: #1a1a1a;
      border: 1px solid #555;
      color: #fff;
      border-radius: 6px;
    }
    .bid-input-group button,
    .bid-button {
      padding: 12px 0;
      font-size: 16px;
      font-weight: bold;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      text-align: center;
    }
    .bid-button {
      width: 100%;
      background-color: #d4af37;
      color: #1a1a1a;
      transition: background-color 0.3s;
    }
    .bid-button:hover { background-color: #e6c567; }
    .bid-button.buy-now {
      background-color: #c82333;
      color: #fff;
    }
    .bid-button.buy-now:hover {
      background-color: #a71d2a;
    }
    .bid-button:disabled {
      background-color: #555;
      color: #999;
      cursor: not-allowed;
    }

    /* 메타 정보 */
    .product-meta {
      margin-top: 20px;
      font-size: 14px;
      color: #aaa;
    }
  </style>
</head>
<body>
  <!-- 공통 헤더 -->
  <jsp:include page="/layout/header/luxury-header.jsp" flush="true"/>

  <div class="detail-main">
    <% if (p != null) { %>
      <div class="detail-container">
        <!-- 이미지 -->
        <div class="product-image-section">
          <% if (p.getImageRenamedName() != null) { %>
            <img src="<%= ctx %>/resources/product_images/<%= p.getImageRenamedName() %>"
                 alt="<%= p.getProductName() %>">
          <% } else { %>
            <img src="https://placehold.co/800x800/2b2b2b/e0e0e0?text=<%= p.getProductName() %>"
                 alt="<%= p.getProductName() %>">
          <% } %>
        </div>

        <!-- 상세 정보 -->
        <div class="product-details-section">
          <p class="artist-name"><%= p.getArtistName() %></p>
          <h1 class="product-title"><%= p.getProductName() %></h1>
          
          <div class="price-info">
            <span class="label">현재가</span>
            <p class="price">₩ <%= df.format(currentPrice) %></p>
          </div>

          <div class="bid-actions">
            <% if ("A".equals(p.getStatus())) { %>
              <% if (isEnded) { %>
                <% if (isSeller) { %>
                  <a href="processWinnerAction.jsp?productId=<%= p.getProductId() %>"
                     class="bid-button">낙찰 처리하기</a>
                <% } else { %>
                  <button class="bid-button" disabled>경매 마감 (낙찰 처리중)</button>
                <% } %>
              <% } else { %>
                <form id="bidForm" class="bid-input-group"
                      action="bidAction.jsp" method="post"
                      onsubmit="return validateBid();">
                  <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                  <input type="hidden" name="currentPrice" value="<%= currentPrice %>">
                  <input type="number" id="bidPriceInput"
                         name="bidPrice" placeholder="입찰 금액" required>
                  <button type="submit" class="bid-button">입찰하기</button>
                </form>
                <% if (p.getBuyNowPrice() > 0 && !isSeller) { %>
                  <a href="paymentAction.jsp?productId=<%= p.getProductId() %>"
                     class="bid-button buy-now"
                     onclick="return confirm('즉시 구매가(₩<%= df.format(p.getBuyNowPrice()) %>)로 구매하시겠습니까?');">
                    즉시 구매
                  </a>
                <% } %>
              <% } %>
            <% } else if ("E".equals(p.getStatus())) { %>
              <p class="price-info">
                <span class="label">최종 낙찰가</span>
                <span class="price">₩ <%= df.format(p.getFinalPrice()) %></span>
              </p>
              <% if (isWinner) { %>
                <a href="paymentAction.jsp?productId=<%= p.getProductId() %>"
                   class="bid-button"
                   onclick="return confirm('마일리지로 결제하시겠습니까?');">
                  결제하기
                </a>
              <% } else { %>
                <button class="bid-button" disabled>경매 종료</button>
              <% } %>
            <% } else if ("P".equals(p.getStatus())) { %>
              <button class="bid-button" disabled>결제 완료</button>
            <% } else { %>
              <button class="bid-button" disabled>종료된 경매입니다</button>
            <% } %>
          </div>

          <div class="description"><%= p.getProductDesc() %></div>
          <div class="product-meta">
            <p>판매자: <%= p.getSellerId() %></p>
            <p>경매 마감: <%= sdf.format(p.getEndTime()) %></p>
            <% if (p.getWinnerId() != null) { %>
              <p style="color:#d4af37; font-weight:bold;">
                낙찰자: <%= p.getWinnerId() %>
              </p>
            <% } %>
          </div>
        </div>
      </div>
    <% } else { %>
      <h2 style="text-align:center; color:#fff; margin:100px 0;">
        해당 상품을 찾을 수 없습니다.
      </h2>
    <% } %>
  </div>

  <!-- 공통 푸터 -->
  <jsp:include page="/layout/footer/luxury-footer.jsp" flush="true"/>

  <script>
    const userMileage  = <%= loginUser.getMileage() %>;
    const currentPrice = <%= currentPrice %>;

    function validateBid() {
      const bidPrice = parseInt(document.getElementById('bidPriceInput').value, 10);

      if (isNaN(bidPrice) || bidPrice <= 0) {
        alert("올바른 입찰 금액을 입력해주세요.");
        return false;
      }
      if (bidPrice > userMileage) {
        alert("보유한 마일리지가 부족합니다.");
        return false;
      }
      if (bidPrice <= currentPrice) {
        alert("입찰가는 현재가보다 높아야 합니다.");
        return false;
      }
      return true;
    }
  </script>
</body>
</html>
