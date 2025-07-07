// src/main/java/com/auction/controller/BidServlet.java
package com.auction.controller;

import com.auction.dao.ProductDAO;
import com.auction.vo.MemberDTO;
import com.auction.vo.ProductDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

import static com.auction.common.JDBCTemplate.*;

@WebServlet("/product/bid")
public class BidServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
            return;
        }

        int productId = Integer.parseInt(request.getParameter("productId"));
        long bidPrice = Long.parseLong(request.getParameter("bidPrice"));

        Connection conn = getConnection();
        ProductDAO dao = new ProductDAO();
        ProductDTO p = dao.selectProductById(conn, productId);
        if (p == null) {
            session.setAttribute("alertMsg", "상품 정보가 없습니다.");
            close(conn);
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        int currentPrice = p.getCurrentPrice();

        if (bidPrice <= currentPrice) {
            session.setAttribute("alertMsg", "입찰가는 현재가보다 높아야 합니다.");
            close(conn);
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }

        int result = dao.updateCurrentPrice(conn, productId, bidPrice);

        if (result > 0) {
            commit(conn);
            session.setAttribute("alertMsg", "입찰 성공!");
        } else {
            rollback(conn);
            session.setAttribute("alertMsg", "입찰 실패");
        }

        close(conn);
        response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
    }
}
