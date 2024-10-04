package projectPhase3;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Reporting {
    public static void main(String[] args) throws SQLException {
        String userName = null;
        String password = null;
        if (args.length == 2) {
            System.err.println("USAGE: java Reporting <username> <password> [Option]\n" +
                    "1- Report Patients Basic Information\n" +
                    "2- Report Doctors Basic Information\n" +
                    "3- Report Admissions Information\n" +
                    "4- Update Admissions Payment");
            return;
        } else if (args.length == 3) {
            userName = args[0];
            password = args[1];


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

            // Now we have the program options
            if (Integer.parseInt(args[2]) == 1) {
                //Reporting Patients Basic Info.
                System.out.println("Hello !!!!");
            } else if (Integer.parseInt(args[2]) == 2) {
                //Reporting Doctors Basic Info

            } else if (Integer.parseInt(args[2]) == 3) {
                //Reporting Admissions Info


            } else if (Integer.parseInt(args[2]) == 4) {
                //Updating Admission Payment

            } else {
                System.err.println("Options must be of [1, 2, 3, 4]");
            }

            connection.close();
        }
    }
}
