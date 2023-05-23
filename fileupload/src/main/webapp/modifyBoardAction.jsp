<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.*" %><!-- cos.jar... -->
<%@ page import = "com.oreilly.servlet.multipart.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*"%> <!-- 타입이 맞지 않는 업로드 된 불필요한 파일을 삭제하기 위해 불러옴 -->
<%
	String loginMemberId = null;
	if(session.getAttribute("loginMemberId") != null) {
		loginMemberId = (String)session.getAttribute("loginMemberId");
	}else{
		//board 추가는 로그인 한 사람만 하게 해준다.
		System.out.println("boardList.jsp로 리턴<---modifyBoardAction.jsp");
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");		
		return;
	}
	final String RESET = "\u001B[0m" ;                           
	final String RED = "\u001B[31m";
	final String BG_RED = "\u001B[41m";
	final String GREEN = "\u001B[32m ";
	final String YELLOW = "\u001B[33m";


	//---DB 호출--------------------------------------------------------//
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl = "jdbc:mariadb://127.0.0.1:3306/fileuplode";
	String dbUser = "root";
	String dbPw = "java1234";	
	Class.forName(driver);
	System.out.println("modifyBoardAction.jsp --> DB 드라이버 로딩 성공");	
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);	
	System.out.println("modifyBoardAction.jsp --> DB 접속성공 "+conn);
	//---DB 호출--------------------------------------------------------//
	
	
	String dir = request.getServletContext().getRealPath("/upload"); // 이 프로젝트 내 upload 파일 호출
	System.out.println(dir + "<--dir-- modifyBoardAction.jsp");
	
	int max = 10 * 1024 * 1024;

	
	// request객체를 multipartRequest의 API를 사용할 수 있도록 랩핑
	// DefaultFileRenamePolicy() 파일 중복이름 방지 -- 후에 다른 방법으로 사용
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	//넘어왔는지 확인l
	System.out.println(BG_RED + mRequest.getOriginalFileName("boardFile") + "<--mReq-- modifyBoardAction.jsp getOriginalFileName" +RESET);
	//요청값 확인
	int boardNo = Integer.parseInt( mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt( mRequest.getParameter("boardFileNo"));
	String boardTitle = mRequest.getParameter("boardTitle");
	String type = mRequest.getContentType("boardFile");
	String saveFilename = mRequest.getFilesystemName("boardFile");
	String originFilename = mRequest.getOriginalFileName("boardFile");
	System.out.println(boardNo+ " <--mReq-- modifyBoardAction boardNo");
	System.out.println(boardFileNo+ " <--mReq-- modifyBoardAction boardFileNo");
	System.out.println(boardTitle+ " <--mReq-- modifyBoardAction boardTitle");
	System.out.println(type+ " <--mReq-- modifyBoardAction type");
	System.out.println(saveFilename+ " <--mReq-- modifyBoardAction saveFilename");
	System.out.println(originFilename+ " <--mReq-- modifyBoardAction originFilename");
	
	//title은 파일첨부 안 해도 무조건 수정
	String boardSql = "UPDATE board SET board_title = ? WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boardRow = boardStmt.executeUpdate();

	//파일이 안 넘어오면 null이다 --> null이면 board 테이블의 title만 수정
	if(mRequest.getOriginalFileName("boardFile") != null ){
		
		//1) board_title 수정
		//pdf파일 유효성 검사. pdf가 아니라면 업로드한 파일 삭제
		if(mRequest.getContentType("boardFile").equals("application/pdf") == false){
			System.out.println("pdf파일이 아닙니다");
			//File을 가져온다 (경로 / saveFilename)의 이름인
			File f = new File(dir+"/"+saveFilename);
			
			//이미 파일은 업데이트가 됐기 때문에 파일이 진짜로 있다면
			if(f.exists()){
				//파일삭제
				f.delete();
				System.out.println(saveFilename + "PDF 파일이 아닙니다. 파일 삭제");
			}
		//pdf파일이라면
		}else{
			//1)이전 파일(saveFIlename) 삭제		2)db수정(update))

			//vo타입에 담기
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setBoardNo(boardNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			System.out.println(YELLOW + boardFile.getBoardFileNo()+"<--vo--modifyBoardAction boardFileNo"+RESET);
			System.out.println(YELLOW + boardFile.getBoardNo()+"<--vo--modifyBoardAction boardFileNo"+RESET);
			System.out.println(YELLOW + boardFile.getType()+"<--vo--modifyBoardAction type"+RESET);
			System.out.println(YELLOW + boardFile.getOriginFilename()+"<--vo--modifyBoardAction originFilename"+RESET);
			System.out.println(YELLOW + boardFile.getSaveFilename()+"<--vo--modifyBoardAction saveFilename"+RESET);
			
			//1)이전 파일 삭제
			String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no =?";
			PreparedStatement saveFileStmt = conn.prepareStatement(saveFilenameSql);
			saveFileStmt.setInt(1, boardFile.getBoardFileNo());
			System.out.println(GREEN+saveFileStmt +"<--stmt--modifyBoardAction saveFileStmt" +RESET);
			ResultSet saveFileRs = saveFileStmt.executeQuery();
			//board_file_no로 select한(이전파일) 세이브파일네임을 담기위한 변수 선언
			String preSaveFilename="";
			//결과값이 있다면
			if(saveFileRs.next()){
				preSaveFilename = saveFileRs.getString("save_filename");
				System.out.println(GREEN +preSaveFilename + "<--- preSaveFilename 이전 파일네임");
			}
			//File을 가져온다 (경로 / preSaveFilename)의 이름인
			File f = new File(dir+"/"+preSaveFilename);
			//파일이 있다면
			if(f.exists()){
				//파일삭제
				System.out.println(preSaveFilename + "<--- pdf파일이고, 업데이트를 위해 이전파일 삭제");
				f.delete();
			}
			
			//2)수정된 파일의 정보로 db를 수정
			String boardFileSql = "UPDATE board_file SET origin_filename=?, save_filename =? WHERE board_file_no = ?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			System.out.println(BG_RED + boardFileStmt + "<--stmt--modifyBoardAction boardFileStmt" + RESET);

			
			//업데이트 됐는지 확인
			int boardFileRow = boardFileStmt.executeUpdate();
			System.out.println(boardFileRow);
			if(boardFileRow > 0){//업데이트 된 행이 0이면 수정이 안된거다.
				System.out.println("수정성공");
			}else{
				System.out.println("수정불가");
			}
		}
	}
	//어쩄든 boardList.jsp로 보내준다.
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
%>