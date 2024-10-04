package projectPhase3;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import Data.MyPersonalInfo;
public class Reporting {
    public static void main(String[] args) throws SQLException {
        String userName = null;
        String password = null;
        if(args.length != 2){
            System.err.println("USAGE: java Reporting <username> <password>");
            return;
        }
        else{
            userName = args[0];
            password = args[1];
        }

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.out.println("Where is your Oracle JDBC Driver? Did you follow the execution steps. ");
            System.out.println("");
            System.out.println("*****Open the file and read the comments in the beginning of the file****");
            System.out.println("");
            e.printStackTrace();
            return;
        }
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(
                    "jdbc:oracle:thin:@oracle.wpi.edu:1521:orcl",
                    userName,
                    password);
            System.out.println("Connection Succes!");
        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }

        connection.close();
    }
}
