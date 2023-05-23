<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	//세션검사
	String loginMemberId = null;
	//세션값이 있으면 넣어준다
	if(session.getAttribute("loginMemberId") != null) {
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}else{//세션아이디가 없으면 리턴
		System.out.println("boardList.jsp로 리턴<---addBoard.jsp");
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");		
		return;
	}
	
	final String RESET = "\u001B[0m" ;                           
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m ";
	final String YELLOW = "\u001B[33m";
	
	//파라미터 검사
	if(request.getParameter("boardNo") == null
	|| request.getParameter("boardFileNo") == null
	|| request.getParameter("boardNo").equals("")
	|| request.getParameter("boardFileNo").equals("")){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");	
		System.out.println("modifyBoardAction.jsp --> boardList.jsp로 리턴");
		return;	
	}
	String boardNo = request.getParameter("boardNo");
	String boardFileNo = request.getParameter("boardFileNo");
	System.out.println(boardNo + " <--parm-- modifyBoardAction.jsp boardNo");
	System.out.println(boardFileNo + " <--parm--modifyBoardAction.jsp boardFileNo");
	
	//---DB 호출--------------------------------------------------------//
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileuplode";
	String dbUser = "root";
	String dbPw = "java1234";	
	Class.forName(driver);
	//System.out.println("modifyBoard.jsp --> DB 드라이버 로딩 성공");	
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);	
	//System.out.println("modifyBoard.jsp --> DB 접속성공 "+conn);
	//---DB 호출종료------------------------------------------------------//
	
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, b.member_id memberId, b.createdate, b.updatedate, f.board_file_no boardFileNo , f.origin_filename originFilename, f.save_filename saveFilename, f.path path, f.type type FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no =? AND f.board_file_no =?";
	PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
	stmt.setString(1, boardNo);
	stmt.setString(2, boardFileNo );
	System.out.println(YELLOW + stmt + " <--stmt-- modifyBoard.jsp boardStmt" +RESET);
	ResultSet rs = stmt.executeQuery();
	HashMap<String, Object> map = null;
	
	if(rs.next()){
		map = new HashMap<>();
		map.put("boardNo", rs.getInt("boardNo"));
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("boardFileNo", rs.getInt("boardFileNo"));
		map.put("originFilename", rs.getString("originFilename"));
	}
	System.out.println(map.get("boardNo") + "<--map--modifyBoard.jsp boardNo ");
	System.out.println(map.get("boardTitle") + "<--map--modifyBoard.jsp boardTitle ");
	System.out.println(map.get("boardFileNo") + "<--map--modifyBoard.jsp boardFileNo ");
	System.out.println(map.get("originFilename") + "<--map--modifyBoard.jsp originFilename ");

	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Modify Board</title>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<style>
	a{
		/* 링크의 라인 없애기  */
		text-decoration: none;
	}
	a:link { 	/* 방문한 적 없는 글자색  */
		color:#4C4C4C; 
	}
	a:visited { /* 방문한 글자색  */
		color:#747474;
	}
	.p2 {/* 본문 폰트 좌정렬*/
		font-family: "Lucida Console", "Courier New", monospace;
		text-align: left;
	}
	.p3 {/* 본문 폰트*/
		font-family: "Lucida Console", "Courier New", monospace;
		text-align: center;
	}
	h1{	/*제목 폰트*/
		font-family: 'Black Han Sans', sans-serif;
		text-align: center;
	}
	h2 {/* h2 왼쪽정렬 */
		text-align: left;
	}
	.button {/* 버튼 스타일 */
	  background-color: #FFD8D8; /* Green */
	  border: none;
	  color: black;
	  padding: 15px 32px;
	  text-align: center;
	  text-decoration: none;
	  display: inline-block;
	  font-size: 16px;
	}
	.button:hover {background-color: #FFB1BC}
	.button:active {
	  background-color: #FFB1BC;
	  box-shadow: 0 5px #666;
	  transform: translateY(4px);
	}
</style>
</head>
<body>
<div class="container">	
	<div align="center">
		<h1>board & boardFile 수정</h1>	
	</div>
	<br>
	<div class="p2" align="center">
		<form action="<%=request.getContextPath()%>/modifyBoardAction.jsp" method="post" enctype="multipart/form-data">
			<input type="hidden" name="boardNo" value="<%=map.get("boardNo")%>">
			<input type="hidden" name="boardFileNo" value="<%=map.get("boardFileNo")%>">
			<table class="table table-bordered">
				<tr>
					<td >Title</td>
					<td>
						<textarea rows="3" cols="50" name="boardTitle" required="required">
							<%=map.get("boardTitle") %>
						</textarea>
					</td>
				</tr>
				<tr>
					<td>Board File</td>
					<td>
						<input type="file" name="boardFile">
						<br>(수정 전 파일 : <%=map.get("originFilename")%>)
					</td>
				</tr>
			</table>
			<div align="center">
				<button class="button" type="submit">수정</button>			
			</div>
		</form>
	</div>
</div>
</body>
</html>