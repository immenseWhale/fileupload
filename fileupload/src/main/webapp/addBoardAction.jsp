<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %><!-- cos.jar... -->
<%@ page import = "com.oreilly.servlet.multipart.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*"%> <!-- 타입이 맞지 않는 업로드 된 불필요한 파일을 삭제하기 위해 불러옴 -->
<%String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null) {
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}else{
		//board 추가는 로그인 한 사람만 하게 해준다.
		System.out.println("boardList.jsp로 리턴<---addBoard.jsp");
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");		
		return;
	}
	final String RESET = "\u001B[0m" ;                           
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m ";
	final String YELLOW = "\u001B[33m";

	String dir = request.getServletContext().getRealPath("/upload"); // 이 프로젝트 내 upload 파일 호출
	System.out.println(dir);
	
	int max = 10 * 1024 * 1024;
	
	// request객체를 multipartRequest의 API를 사용할 수 있도록 랩핑
	// DefaultFileRenamePolicy() 파일 중복이름 방지 -- 후에 다른 방법으로 사용
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	//업로드 파일이 pdf 파일이 아니면 리턴하겠다. cos.jar에서는 이미 파일이 들어온 이후다.--> 삭제 API import="java.io.File"
	if(mRequest.getContentType("boardFile").equals("application/pdf") == false){
		//이미 저장된 파일 삭제 후 리턴
		String saveFilename = mRequest.getFilesystemName("boardFile");
		//File을 가져온다 (경로 / saveFilename)의 이름인
		File f = new File(dir+"\\"+saveFilename);
		//파일이 진짜로 있다면
		if(f.exists()){
			f.delete();
		}
		//리턴
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
	}
	
	// 1) input type ="text" 반환 API
	// board 테이블에 저장
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	
	System.out.println(boardTitle + "<--boardTitle");
	System.out.println(memberId + "<--memberId");
	
	Board board = new Board(); // 저장 (1)
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	// 2) input type = "file" 값(파일 메타 정보)반환 API(원본 파일 이름, 저장된 파일 이름, 컨텐츠 타입) 받아옴
	// board_file 테이블에 저장
	// 파일(바이너리)은 이미 (request랩핑시 12라인)에서 저장
	String type = mRequest.getContentType("boardFile"); // boardFile 받아온다. api 받는 타입 다름
	String originFilename = mRequest.getOriginalFileName("boardFile");
	String saveFilename = mRequest.getFilesystemName("boardFile");
	
	System.out.println(type + "<--type");
	System.out.println(originFilename + "<--originFilename");
	System.out.println(saveFilename + "<--saveFilename");
	
	BoardFile boardFile = new BoardFile(); // 저장(2)
	// boardFile.setBoardNo(boardNo);
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	//---DB 호출--------------------------------------------------------//
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileuplode";
	String dbUser = "root";
	String dbPw = "java1234";	
	Class.forName(driver);
	System.out.println("addBoardAcion.jsp --> DB 드라이버 로딩 성공");	
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);	
	System.out.println("addBoardAcion.jsp --> DB 접속성공 "+conn);
	//---DB 호출--------------------------------------------------------//
	/*
		삽입 sql 2개
		
		1.INSERT INTO board(board_title, member_id, updatedate, createdate) values(?,?,now(), now());
	
								board_no가 위의 문장이 실행되어야 알 수 있는 문제
		2.INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate)
			valuse(?,?,?,?,?, now());
	*/
	String boardSql = "INSERT INTO board(board_title, member_id, updatedate, createdate) values(?, ?, now(), now())";
	//                                                            sql문에서 GENERATED_KEYS를 받아오는 명령
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId );
	System.out.println(YELLOW + boardStmt + " <--stmt-- addBoardAcion boardStmt" +RESET);
	boardStmt.executeUpdate();
	
	//결과값에 GENERATED_KEYS 받아온다.
	ResultSet keyRs = boardStmt.getGeneratedKeys();
	int boardNo = 0;
	if(keyRs.next()){
		boardNo = keyRs.getInt(1);
	}
	int boardRow = boardStmt.executeUpdate();
	/*
		INSERT 쿼리 실행 후 기본키값 받아오는 JDBC API
		String sql = "INSERT 쿼리";
		pstmt = conn.PreparedStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
		int row = pstmt.executeUpdate(); // insert 쿼리 실행
		REsultSet keyRs = pstmt.getCeneratedKeys(); // insert 후 입력된 행의 키 값을 받아오는 select
		int keyValue = 0;
		if(keyRs.next()){
			keyValue = rs.getInt(1);
		}
		}
	*/
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) values(?,?,?,?,?,now())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type);
	fileStmt.setString(5, "upload");
	System.out.println(YELLOW + fileStmt + " <--stmt-- addBoardAcion fileStmt" +RESET);
	fileStmt.executeUpdate(); // board_file 입력
	
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");

%>