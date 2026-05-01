import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

class DataBase {

    // 1. 建立与 MySQL 服务连接 (请在此处替换你的密码)
    static final String DB_URL_BASE = "jdbc:mysql://127.0.0.1:3306/?serverTimezone=Asia/Shanghai&characterEncoding=UTF-8";
    static final String DB_URL_WITH_DB = "jdbc:mysql://127.0.0.1:3306/library_db?serverTimezone=Asia/Shanghai&characterEncoding=UTF-8";
    static final String USER = "root";
    static final String PASS = "You4682159"; // 填写你的数据库密码

    public static void main(String[] args) {
        // 第一步：先连接基础URL，创建数据库
        try (Connection connBase = DriverManager.getConnection(DB_URL_BASE, USER, PASS);
                Statement stmtBase = connBase.createStatement()) {

            System.out.println("========== 1. 建立数据库连接并创建数据库 ==========");
            System.out.println("成功连接到 MySQL!");

            // 2. 为图书馆借阅系统创建数据库
            stmtBase.executeUpdate("CREATE DATABASE IF NOT EXISTS library_db");
            System.out.println("成功创建数据库: library_db");

        } catch (SQLException e) {
            e.printStackTrace();
            return; // 如果连基础连接都失败，直接退出
        }

        System.out.println("\n");

        // 第二步：连接到刚刚创建的 library_db，进行表操作
        try (Connection conn = DriverManager.getConnection(DB_URL_WITH_DB, USER, PASS);
                Statement stmt = conn.createStatement()) {

            System.out.println("========== 2. 创建 3 张数据表 ==========");

            // 为了可以反复运行测试，先删除旧表（注意有外键依赖，按特定顺序删除）
            stmt.executeUpdate("DROP TABLE IF EXISTS Borrow");
            stmt.executeUpdate("DROP TABLE IF EXISTS Student");
            stmt.executeUpdate("DROP TABLE IF EXISTS Book");

            // 创建 Student 表
            String createStudentSQL = "CREATE TABLE Student (" +
                    "sid VARCHAR(20) PRIMARY KEY, " +
                    "sname VARCHAR(50) NOT NULL, " +
                    "age INT)";
            stmt.executeUpdate(createStudentSQL);
            System.out.println("创建表: Student 成功");

            // 创建 Book 表
            String createBookSQL = "CREATE TABLE Book (" +
                    "bid VARCHAR(20) PRIMARY KEY, " +
                    "bname VARCHAR(100) NOT NULL, " +
                    "author VARCHAR(50))";
            stmt.executeUpdate(createBookSQL);
            System.out.println("创建表: Book 成功");

            // 创建 Borrow 表 (借阅记录)
            String createBorrowSQL = "CREATE TABLE Borrow (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "sid VARCHAR(20), " +
                    "bid VARCHAR(20), " +
                    "borrow_date DATE, " +
                    "FOREIGN KEY (sid) REFERENCES Student(sid), " +
                    "FOREIGN KEY (bid) REFERENCES Book(bid))";
            stmt.executeUpdate(createBorrowSQL);
            System.out.println("创建表: Borrow 成功\n");

            System.out.println("========== 3. 为 3 张数据表分别插入 5 条数据 ==========");
            // 插入 Student 数据
            String insertStudent = "INSERT INTO Student (sid, sname, age) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(insertStudent)) {
                Object[][] students = {
                        { "S01", "张三", 20 },
                        { "S02", "李四", 21 },
                        { "S03", "王五", 19 },
                        { "S04", "赵六", 22 },
                        { "S05", "孙七", 20 }
                };
                for (Object[] s : students) {
                    pstmt.setString(1, (String) s[0]);
                    pstmt.setString(2, (String) s[1]);
                    pstmt.setInt(3, (Integer) s[2]);
                    pstmt.executeUpdate();
                }
            }
            System.out.println("插入 5 条 Student 数据成功");

            // 插入 Book 数据
            String insertBook = "INSERT INTO Book (bid, bname, author) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(insertBook)) {
                Object[][] books = {
                        { "B01", "数据库系统概念", "Abraham" },
                        { "B02", "Java编程思想", "Bruce Eckel" },
                        { "B03", "算法导论", "Thomas H. Cormen" },
                        { "B04", "计算机网络", "谢希仁" },
                        { "B05", "深入理解计算机系统", "Randal E. Bryant" }
                };
                for (Object[] b : books) {
                    pstmt.setString(1, (String) b[0]);
                    pstmt.setString(2, (String) b[1]);
                    pstmt.setString(3, (String) b[2]);
                    pstmt.executeUpdate();
                }
            }
            System.out.println("插入 5 条 Book 数据成功");

            // 插入 Borrow 数据
            String insertBorrow = "INSERT INTO Borrow (sid, bid, borrow_date) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(insertBorrow)) {
                Object[][] borrows = {
                        { "S01", "B01", "2024-04-01" },
                        { "S01", "B02", "2024-04-05" },
                        { "S02", "B03", "2024-04-10" },
                        { "S03", "B04", "2024-04-15" },
                        { "S04", "B05", "2024-04-20" }
                };
                for (Object[] br : borrows) {
                    pstmt.setString(1, (String) br[0]);
                    pstmt.setString(2, (String) br[1]);
                    pstmt.setString(3, (String) br[2]);
                    pstmt.executeUpdate();
                }
            }
            System.out.println("插入 5 条 Borrow 数据成功\n");

            System.out.println("========== 4. 查询学生表中的所有数据 ==========");
            ResultSet rsStudent = stmt.executeQuery("SELECT * FROM Student");
            System.out.println("学号\t姓名\t年龄");
            System.out.println("-------------------------");
            while (rsStudent.next()) {
                System.out.println(rsStudent.getString("sid") + "\t" +
                        rsStudent.getString("sname") + "\t" +
                        rsStudent.getInt("age"));
            }
            rsStudent.close();
            System.out.println("\n");

            System.out.println("========== 5. 自定义多表查询 ==========");
            // 查询谁(姓名)在什么时间借了哪本书(书名)
            String multiTableQuery = "SELECT s.sname, b.bname, br.borrow_date " +
                    "FROM Borrow br " +
                    "JOIN Student s ON br.sid = s.sid " +
                    "JOIN Book b ON br.bid = b.bid";
            ResultSet rsMulti = stmt.executeQuery(multiTableQuery);
            System.out.println("借阅人\t借阅时间\t书名");
            System.out.println("----------------------------------------");
            while (rsMulti.next()) {
                System.out.println(rsMulti.getString("sname") + "\t" +
                        rsMulti.getString("borrow_date") + "\t" +
                        rsMulti.getString("bname"));
            }
            rsMulti.close();
            System.out.println("\n");

            System.out.println("========== 6. 修改学生年龄并打印 ==========");
            // 将 S01 的年龄修改为 25 岁
            stmt.executeUpdate("UPDATE Student SET age = 25 WHERE sid = 'S01'");
            System.out.println("已将学号为 S01 的学生年龄修改为 25 岁。");

            ResultSet rsStudentUpdated = stmt.executeQuery("SELECT * FROM Student");
            System.out.println("--- 修改后的学生表数据 ---");
            System.out.println("学号\t姓名\t年龄");
            while (rsStudentUpdated.next()) {
                System.out.println(rsStudentUpdated.getString("sid") + "\t" +
                        rsStudentUpdated.getString("sname") + "\t" +
                        rsStudentUpdated.getInt("age"));
            }
            rsStudentUpdated.close();
            System.out.println("\n");

            System.out.println("========== 7. 删除部分元组操作并打印 ==========");
            // 删除 S01 的所有借阅记录
            stmt.executeUpdate("DELETE FROM Borrow WHERE sid = 'S01'");
            System.out.println("已删除学号为 S01 的所有借阅记录。");

            ResultSet rsBorrowAfterDelete = stmt.executeQuery("SELECT * FROM Borrow");
            System.out.println("--- 删除操作后的借阅表数据 ---");
            System.out.println("记录ID\t学号\t书籍编号\t借阅日期");
            while (rsBorrowAfterDelete.next()) {
                System.out.println(rsBorrowAfterDelete.getInt("id") + "\t" +
                        rsBorrowAfterDelete.getString("sid") + "\t" +
                        rsBorrowAfterDelete.getString("bid") + "\t\t" +
                        rsBorrowAfterDelete.getString("borrow_date"));
            }
            rsBorrowAfterDelete.close();
            System.out.println("\n");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
