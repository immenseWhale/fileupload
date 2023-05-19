<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.net.*" %>
<%@ page import = "vo.*" %>

<%
	final String RESET = "\u001B[0m" ;                           
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m ";
	final String YELLOW = "\u001B[33m";

	
	//세선 유효성 검사가 최우선 --> 요청값 유효성 검사
	if(session.getAttribute("loginMemberId") != null) {
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}

	//요청값 유효성 검사	
	if(request.getParameter("memberId") == null ||			//memberId가 null이거나 공백이고
	request.getParameter("memberId").equals("") ||	
	request.getParameter("memberPw") == null||				//memberPw가 null이거나 공백이면
	request.getParameter("memberPw").equals("") ){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;												//home으로 돌려보낸다.
	}
	
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");	
	System.out.println(memberId + "<-- loginAction memberId");
	System.out.println(memberPw + "<-- loginAction memberPw");
	
	//vo타입 묶기
	Member paramMember = new Member();
	paramMember.setMemberId(memberId);
	paramMember.setMemberPw(memberPw);
	
	//---DB 호출--------------------------------------------------------//
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileuplode";
	String dbUser = "root";
	String dbPw = "java1234";	
	Class.forName(driver);
	System.out.println("boardList.jsp --> DB 드라이버 로딩 성공");	
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);	
	System.out.println("boardList.jsp --> DB 접속성공 "+conn);
	//---DB 호출--------------------------------------------------------//
	
	PreparedStatement stmt = null;
	ResultSet rs = null;
	
	String sql = "select member_id from member where member_id=? AND member_pw = password(?)";
	stmt = conn.prepareStatement(sql);
	stmt.setString(1, paramMember.getMemberId());
	stmt.setString(2, paramMember.getMemberPw());
	rs = stmt.executeQuery();
	
	if(rs.next()){
		//로그인 성공. 세션에 로그인 정보(id) 저장
		session.setAttribute("loginMemberId", rs.getString("member_id"));
		System.out.println(YELLOW+"loginAction 로그인 성공. 세선졍보 : "+session.getAttribute("loginMemberId")+ RESET);
	}else{
		//로그인 실패
		System.out.println(BG_RED+"loginAction 로그인 실패"+ RESET);
	}
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	return;
	
	
%>