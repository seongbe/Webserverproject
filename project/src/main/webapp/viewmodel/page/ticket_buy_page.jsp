<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/viewmodel/header/header2.jsp" %>
<%@ page import="java.sql.*, java.io.StringWriter, java.io.PrintWriter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>좌석 선택 페이지</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .stadium {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 20px;
        }
        .seats {
            display: grid;
            grid-template-columns: repeat(10, 30px);
            grid-gap: 10px;
        }
        .seat {
            width: 30px;
            height: 30px;
            background-color: #ccc;
            border: 1px solid #ddd;
            cursor: pointer;
        }
        .seat.selected {
            background-color: #6c757d;
        }
        .seat.occupied {
            background-color: #ff4d4d;
            cursor: not-allowed;
        }
        .seat-info {
            margin-top: 20px;
        }
        .container {
            margin-top: 10%;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mb-4">FC라플 vs FC의정부</h1>

        <!-- 경기 정보 -->
        <div class="row mb-4">
            <div class="col-md-8">
                <div class="stadium">
                    <div class="seats">
                        <%-- 좌석을 반복하여 생성 --%>
                        <%
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/seongdb", "root", "12rhtmdqja");
                            out.println("DB 연결 성공<br>"); // 디버깅 로그
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery("SELECT seat_id, is_occupied FROM seats");
                            out.println("쿼리 실행 성공<br>"); // 디버깅 로그

                            while (rs.next()) {
                                int seatId = rs.getInt("seat_id");
                                boolean isOccupied = rs.getBoolean("is_occupied");
                                String occupiedClass = isOccupied ? "occupied" : "";
                                out.println("<div class='seat " + occupiedClass + "' data-seat='" + seatId + "'></div>");
                            }
                        } catch (Exception e) {
                            StringWriter sw = new StringWriter();
                            PrintWriter pw = new PrintWriter(sw);
                            e.printStackTrace(pw);
                            out.print("오류 발생: " + sw.toString()); // 스택 트레이스를 문자열로 출력
                        } finally {
                            if (rs != null) rs.close();
                            if (stmt != null) stmt.close();
                            if (conn != null) conn.close();
                        }
                        %>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <ul class="list-group seat-info">
                    <li class="list-group-item">운영진석(A1-A10)</li>
                    <li class="list-group-item">VIP석(B1-B10)</li>
                    <li class="list-group-item">일반석(C1-H10)</li>
                </ul>
            </div>
        </div>

        <!-- 좌석 선택 버튼 -->
        <div class="d-flex justify-content-between">
            <button class="btn btn-success" id="autoAssign">자동배정</button>
            <button class="btn btn-primary" id="selectSeat">좌석선택</button>
            <button class="btn btn-primary" id="purchaseTicket">티켓구매</button>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const seats = document.querySelectorAll('.seat:not(.occupied)');
            const selectedSeats = new Set();

            seats.forEach(seat => {
                seat.addEventListener('click', () => {
                    if (seat.classList.contains('selected')) {
                        seat.classList.remove('selected');
                        selectedSeats.delete(seat.dataset.seat);
                    } else {
                        seat.classList.add('selected');
                        selectedSeats.add(seat.dataset.seat);
                    }
                });
            });

            document.getElementById('autoAssign').addEventListener('click', () => {
                const availableSeats = Array.from(seats).filter(seat => !seat.classList.contains('selected'));
                if (availableSeats.length > 0) {
                    const randomSeat = availableSeats[Math.floor(Math.random() * availableSeats.length)];
                    randomSeat.classList.add('selected');
                    selectedSeats.add(randomSeat.dataset.seat);
                    alert('랜덤 좌석이 배정되었습니다: ' + randomSeat.dataset.seat);
                } else {
                    alert('모든 좌석이 이미 선택되었습니다.');
                }
            });

            document.getElementById('selectSeat').addEventListener('click', () => {
                alert('선택된 좌석: ' + Array.from(selectedSeats).join(', '));
            });

            document.getElementById('purchaseTicket').addEventListener('click', () => {
                const seatsToBook = Array.from(selectedSeats);
                if (seatsToBook.length > 0) {
                    const seatParam = seatsToBook.join(',');
                    window.location.href = `bookSeats.jsp?seats=${seatParam}`;
                } else {
                    alert('선택된 좌석이 없습니다.');
                }
            });
        });
    </script>
</body>
</html>