<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "vo.*" %>
<%
	final String RESET = "\u001B[0m" ;                           
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m ";
	final String YELLOW = "\u001B[33m";
	
	//현재 페이지
	int currentPage = 1;
	//페이지가 넘어와서 응답값이 null이 아니라면
	if(request.getParameter("currentPage") != null) {
		//currentPage에 응답값 currentPage을 넣어준다.
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	//System.out.println(currentPage + " <--currentPage");
	
	//페이지당 출력할 행의 수	
	int rowPerPage = 4;	
	//시작 행 번호	
	int startRow = (currentPage-1)*rowPerPage;		//1페이지 일 때만 startRow가 0이다
	
	
	//---DB 호출--------------------------------------------------------//
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileuplode";
	String dbUser = "root";
	String dbPw = "java1234";	
	Class.forName(driver);
	//System.out.println("boardList.jsp --> DB 드라이버 로딩 성공");	
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);	
	//System.out.println("boardList.jsp --> DB 접속성공 "+conn);
	//---DB 호출--------------------------------------------------------//
	
	/*	JOIN 문
		SELECT
			b.board_no boardNo
			, b.board_title boardTitle
			, b.member_id memberId
			, b.createdate
			, b.updatedate
			, f.origin_filename originFilename
			, f.save_filename saveFilename
			, f.path path
			, f.type type
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC LIMIT ?, ?
	*/
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, b.member_id memberId, b.createdate, b.updatedate, f.board_file_no boardFileNo , f.origin_filename originFilename, f.save_filename saveFilename, f.path path, f.type type FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC LIMIT ?, ?";
	PreparedStatement stmt = conn.prepareStatement(sql); // 
	stmt.setInt(1, startRow);
	stmt.setInt(2, rowPerPage);
	//System.out.println(GREEN + stmt + " <--stmt-- boardList.jsp boardStmt" +RESET);
	ResultSet rs = stmt.executeQuery();	
	//vo타입 Board ArrayList 선언
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", rs.getInt("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("memberId", rs.getString("memberId"));
		m.put("createdate", rs.getString("createdate"));
		m.put("updatedate", rs.getString("updatedate"));
		m.put("boardFileNo", rs.getInt("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		m.put("type", rs.getString("type"));
		list.add(m);
	}
	//System.out.println(YELLOW + list + " <--ArrayList-- addBoardAcion list" +RESET);

	//마지막 페이지 구하는 sql
	PreparedStatement stmt2 = conn.prepareStatement("select count(*) from board");
	ResultSet rs2 = stmt2.executeQuery();
	int totalRow = 0; // SELECT COUNT(*) FROM notice;
	if(rs2.next()) {
		totalRow = rs2.getInt("count(*)");
	}
	//마지막 페이지 = 총 행 / 페이지당 행
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0) {
		//마지막에 여분이 있는 페이지 보여주려고 +1
		lastPage = lastPage + 1;
	}
 	int pageRange = 2; // 현재 페이지 주변에 보여줄 페이지의 수
 	//Math.max --> 값들 중 가장 큰 값 반환  Math.min --> 값들 중 가장 작은 값 반환
    int startPage = Math.max(1, currentPage - pageRange); // 현재 페이지 주변의 첫 페이지 번호 계산
    int endPage = Math.min(lastPage, currentPage + pageRange); // 현재 페이지 주변의 마지막 페이지 번호 계산
	
	//boardList는 로그인 하지 않아도 값을 보여주니까 세션 검사 뒤에
	String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null) {
		loginMemberId = (String)session.getAttribute("loginMemberId");
		//System.out.println(loginMemberId + "<--boardList.jsp loginMemberId");
	}
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Board List</title>
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
</style>
</head>
<body>
<!----------------------- 로그인하지 않았다면 로그인 폼, 로그인 했다면 수정 삭제 앵커 보여주겠다-->
<div align="center">
<%
	if(session.getAttribute("loginMemberId") == null) { // 로그인전이면 로그인폼출력
%>
	<form action="<%=request.getContextPath()%>/loginAction.jsp" method="post"  >
		<table>
			<tr>
				<td>
					ID
				</td>
				<td>
					<input type="text" name="memberId">
				</td>
				<td>
					Password
				</td>
				<td>
					<input type="password" name="memberPw">
				</td>
				<td>
					<button type="submit">login</button>
				</td>
			</tr>
		</table>              
	</form>
<%  
	} else { //로그인후
%>
	<div>
		<%=session.getAttribute("loginMemberId") %>님</a>
	</div>
	<div>
		<a href="<%=request.getContextPath()%>/addBoard.jsp?">PDF 추가</a>
	</div>
<%    
	}
%> 

</div>
	
<!----------------------- board List 출력 -->
<div>
	<table class="table table-bordered">
		<tr>
			<th>Board No</th>
			<th>Board Title</th>
			<th>Member ID</th>
			<th>Origin File Name</th>
			<th>File Type</th>		
			<th>Save File Name</th>	
			<th>Board File No</th>
			<th>Create Date</th>	
			<th>Update Date</th>	
			<th colspan="2">Edit</th>
		</tr>
		<%
			//notice 사이즈만큼 반복되는 배열로 re.next를 대신한다.
			for(HashMap<String, Object> m : list){
		%>				
			<tr>	
				<td><%=m.get("boardNo")%> </td>
				<td><%=m.get("boardTitle")%> </td>
				<td><%=m.get("memberId")%> </td>
				<td>
					<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">						
						<%=m.get("originFilename")%> 
					</a>
				</td>
				<td><%=m.get("type")%> </td>
				<td><%=m.get("saveFilename")%> </td>				
				<td><%=m.get("boardFileNo")%> </td>
				<td><%=m.get("createdate")%> </td>
				<td><%=m.get("updatedate")%> </td>
			<% //memberId가 null이 아니고, board id와 같다면 수정 삭제를 보여주고, 가능하게 하겠다.
				if(loginMemberId != null && loginMemberId.equals(m.get("memberId"))) {
			%>	
					<td>
						<form action="<%=request.getContextPath()%>/modifyBoard.jsp" method="get">
							<input type="hidden" name="boardNo" value="<%=m.get("boardNo")%>">
							<input type="hidden" name="boardFileNo" value="<%=m.get("boardFileNo")%>">
							<button type="submit">수정</button>
						</form>
					</td>
					<td>
						<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method="post" enctype="multipart/form-data">
							<input type="hidden" name="boardNo" value="<%=m.get("boardNo")%>">
							<input type="hidden" name="saveFilename" value="<%=m.get("saveFilename")%>">
							<input type="hidden" name="path" value="<%=m.get("path")%>">			
							<input type="hidden" name="memberId" value="<%=m.get("memberId")%>">
							<button type="submit">삭제</button>
						</form>
					</td>
			<%
				}else{
			%>
				<td>본인전용</td>
				<td>본인전용</td>
			<%
				}
			%>
			</tr>
		<%		
			}
		%>	
	</table>
</div>
<!---------------------------페이징  -->
<div align="center">
<% 	//페이지가 1 이상이면 이전 페이지 보여주기
	if (startPage > 1) {
%>
		<a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=1%>">1</a>
		<span>...</span>
<%
     } 
     
	for (int i = startPage; i <= endPage; i+=1) { 
		if (i == currentPage) {
%>
			<span><%=i%></span>
<%
		} else {
%>
			<a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=i%>"><%=i%></a>
<% 
		} 
	} 	
	if (endPage < lastPage) {
%>
		<span>...</span>
		<a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=lastPage%>"><%=lastPage%></a>
<% 
	}
%>
</div>


</body>
</html>