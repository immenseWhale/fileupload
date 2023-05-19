<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	//memberId 선언과 세션 로그인 ID가 널이 아니면 넣어준다.
	String loginMemberId = "test";
	if(session.getAttribute("loginMemberId") != null) {
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}else{
		//board 추가는 로그인 한 사람만 하게 해준다.
		System.out.println("boardList.jsp로 리턴<---addBoard.jsp");
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");		
		return;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Board</title>
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
	<h1>PDF 자료 업로드</h1>
	<!-- enctype = multipart/form-data & post방식 -->
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" method="post" enctype="multipart/form-data">
		<table class="table table-bordered ">
	<!---------------------  자료 업로드 제목 -->
			<tr>
				<th>Board Title</th>
				<td><!-- required : 폼 공백일 시 submit(X) -->
					<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea>
				</td>
			</tr>
			
	<!---------------------  로그인 사용자 아이디 -->
			<tr>
				<th>Member ID</th>
				<td>
					<input type="text" name="memberId" value="<%=loginMemberId%>" readonly="readonly">
				</td>
			</tr>
			
	<!--------------------- 파일 업로드 -->
			<tr>
				<th>Board File</th><!-- vo -->
				<td>
					<input type="file" name="boardFile" required="required">
				</td>
			</tr>
		</table>
		<button type="submit">자료업로드</button>
	</form>
</body>
</html>