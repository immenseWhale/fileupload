<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %><!-- cos.jar... -->
<%@ page import = "com.oreilly.servlet.multipart.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*"%> <!-- 타입이 맞지 않는 업로드 된 불필요한 파일을 삭제하기 위해 불러옴 -->
<%
	//세션검사
	String loginMemberId = null;
	//세션값이 있으면 넣어준다
	if(session.getAttribute("loginMemberId") != null) {
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}else{//세션아이디가 없으면 리턴
		System.out.println("boardList.jsp로 리턴<---removeBoardAction.jsp");
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");		
		return;
	}
	final String RESET = "\u001B[0m" ;                           
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m ";
	final String YELLOW = "\u001B[33m";
	
	// 이 프로젝트 내 upload 파일 호출
	String dir = request.getServletContext().getRealPath("/upload"); 
	System.out.println(dir + "<--dir-- removeBoardAction.jsp");
	int max = 10 * 1024 * 1024;

	// request객체를 multipartRequest의 API를 사용할 수 있도록 랩핑
	// DefaultFileRenamePolicy() 파일 중복이름 방지 -- 후에 다른 방법으로 사용
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	//form에서 보내준 값들 받아온다
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	String memberId = mRequest.getParameter("memberId");
	String saveFilename = mRequest.getParameter("saveFilename");
	System.out.println(boardNo+"<--mReq-- removeBoardAction.jsp boardNo");
	System.out.println(memberId+"<--mReq--removeBoardAction.jsp memberId");
	System.out.println(saveFilename+"<--mReq-- removeBoardAction.jsp saveFilename");
	
	
	//세션 아이디와 memberID가 같은지 확인한다
	if(!loginMemberId.equals(memberId)){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");	
		System.out.println(BG_RED + "removeBoardAction.jsp 아이디 불일치--> boardList.jsp로 리턴" +RESET);
	}	
	
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
		
	//board_no 값으로  DB에서 삭제한다. CASCADE옵션 적용되어있으므로 board에서만 삭제해도 삭제된다.
	String delSql = "DELETE FROM board where board_no =?";
	PreparedStatement delStmt = conn.prepareStatement(delSql);
	delStmt.setInt(1, boardNo);
	System.out.println(YELLOW + delStmt + " <---stmt-- removeBoardAction delStmt" + RESET);
	
	//똑바로 들어갔다면 한 행만 갱신됐다고 뜰 것이다.
	int rowsDeleted = delStmt.executeUpdate();
	if (rowsDeleted > 0) {
		//행이 삭제 됐다면 파일도 지운다.
		//File을 가져온다 (경로 / saveFilename)의 이름인
		File f = new File(dir+"/"+saveFilename);
		
		//이미 파일은 업데이트가 됐기 때문에 파일이 진짜로 있다면
		if(f.exists()){
			//파일삭제
			f.delete();
			System.out.println(BG_RED + saveFilename + "행이 삭제되었으니, 파일도 삭제합니다." +RESET);
		}
	    response.sendRedirect(request.getContextPath() + "/boardList.jsp");
	    System.out.println(GREEN + " 모두 삭제 성공 후 boardList로 리턴. removeBoardAction" + RESET);
	    return;
	} else {
	    System.out.println(YELLOW + "삭제된 row가 없습니다." + RESET);
	}

%>