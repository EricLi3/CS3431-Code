package projectPhase3;

import oracle.sql.NUMBER;

import java.sql.*;
import java.util.Scanner;


public class Reporting {
    public static void main(String[] args) throws SQLException {
        String userName;
        String password;
        Connection connection = null;
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
                System.out.println("Where is your Oracle JDBC Driver? Did you follow the execution steps. \n");
                System.out.println("*****Open the file and read the comments in the beginning of the file****\n");
                e.printStackTrace();
                return;
            }
            connection = null;
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
                Scanner scanner = new Scanner(System.in);
                System.out.print("Enter Patient SSN: ");
                String ssn = scanner.nextLine();

                String query = "SELECT PATIENTSSN, PATIENTFNAME, PATIENTLNAME, PATIENTADDRESS FROM PATIENT WHERE PATIENTSSN = ?";
                PreparedStatement preparedStatement = connection.prepareStatement(query);
                preparedStatement.setString(1, ssn);

                ResultSet resultSet = preparedStatement.executeQuery();

                // Process the results and print the patient information
                if (resultSet.next()) {
                    String patientSSN = resultSet.getString("PATIENTSSN");
                    String patientFName = resultSet.getString("PATIENTFNAME");
                    String patientLName = resultSet.getString("PATIENTLNAME");
                    String patientAddress = resultSet.getString("PATIENTADDRESS");

                    System.out.println("Patient SSN: " + patientSSN);
                    System.out.println("Patient First Name: " + patientFName);
                    System.out.println("Patient Last Name: " + patientLName);
                    System.out.println("Patient Address: " + patientAddress);
                } else {
                    System.out.println("Patient with SSN " + ssn + " not found.");
                }

                // Close the resources
                resultSet.close();
                preparedStatement.close();

            } else if (Integer.parseInt(args[2]) == 2) {
                //Reporting Doctors Basic Info
                Scanner scanner = new Scanner(System.in);
                System.out.print("Enter Doctor ID: ");
                int docID = scanner.nextInt();

                String query = "SELECT DOCTOR.EMPLOYEEID, GENDER, SPECIALTY, GRADUATEDFROM, FName, LNAME\n" +
                        "FROM DOCTOR, EMPLOYEE\n" +
                        "WHERE EMPLOYEEID = ? AND ID = ? AND JOBTITLE = 'Doctor'";


                // Prepare the statement to prevent SQL injection
                try (PreparedStatement preparedStatement = connection.prepareStatement(query);) {
                    preparedStatement.setInt(1, docID);
                    preparedStatement.setInt(2, docID);


                    ResultSet resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String doctorID = resultSet.getString("EMPLOYEEID");
                        String doctorFName = resultSet.getString("FNAME");
                        String doctorLName = resultSet.getString("LNAME");
                        String docGender = resultSet.getString("GENDER");
                        String gradFrom = resultSet.getString("GRADUATEDFROM");
                        String specialty = resultSet.getString("SPECIALTY");


                        System.out.println("Doctor ID: " + doctorID);
                        System.out.println("Doctor First Name: " + doctorFName);
                        System.out.println("Doctor Last Name: " + doctorLName);
                        System.out.println("Doctor Gender: " + docGender);
                        System.out.println("Doctor Graduated From: " + gradFrom);
                        System.out.println("Doctor Specialty: " + specialty);
                    } else {
                        System.out.println("Doctor not found.");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }


            } else if (Integer.parseInt(args[2]) == 3) {
                //Reporting Admissions Info
                Scanner scanner = new Scanner(System.in);
                System.out.print("Enter Admission Number: ");
                int admissionNum = scanner.nextInt();

                String AdmissionQuery = "SELECT ADMISSIONNUM, PATIENTSSN, ADMISSIONDATE, TOTALPAYMENT\n" +
                        "FROM ADMISSION\n" +
                        "WHERE ADMISSIONNUM = ?";
                String RoomQuery = "SELECT ROOMNUM, STARTDATE, ENDDATE FROM STAYIN WHERE ADMISSIONNUM = ?";
                String ExamineQuery = "SELECT DOCTORID FROM EXAMINE WHERE ADMISSIONNUM = ?";

                PreparedStatement admissionStatement = null;
                PreparedStatement roomStatement = null;
                PreparedStatement examineStatement = null;

                // Prepare Admission Query
                admissionStatement = connection.prepareStatement(AdmissionQuery);
                admissionStatement.setInt(1, admissionNum);

                // Prepare Room Query
                roomStatement = connection.prepareStatement(RoomQuery);
                roomStatement.setInt(1, admissionNum);

                // Prepare Examine Query
                examineStatement = connection.prepareStatement(ExamineQuery);
                examineStatement.setInt(1, admissionNum);


                // run the queries
                ResultSet admissionResults = admissionStatement.executeQuery();
                if (admissionResults.next()) { // Check if there are results

                    int admission_number = admissionResults.getInt("ADMISSIONNUM");
                    String patientSSN = admissionResults.getString("PATIENTSSN");
                    Date Admissiondate = admissionResults.getDate("ADMISSIONDATE");
                    Double TotalPayment = admissionResults.getDouble("TOTALPAYMENT");


                    System.out.println("Admission Number: " + admission_number);
                    System.out.println("Doctor First Name: " + patientSSN);
                    System.out.println("Admission date (start date): " + Admissiondate);
                    System.out.println("Total Payment: " + TotalPayment);
                }

                ResultSet roomResults = roomStatement.executeQuery();

                System.out.println("Rooms:");
                while (roomResults.next()) {
                    int roomNum = roomResults.getInt("ROOMNUM");
                    Date fromDate = roomResults.getDate("STARTDATE");
                    Date toDate = roomResults.getDate("ENDDATE");

                    System.out.println("RoomNum: " + roomNum);
                    System.out.println("FromDate: " + fromDate);
                    System.out.println("ToDate: " + toDate);
                }


                ResultSet examineResults = examineStatement.executeQuery();

                System.out.println("Doctors examined the patient in this admission:");
                while (examineResults.next()) {
                    int doctorID = examineResults.getInt("DOCTORID");

                    System.out.println("Doctor ID: " + doctorID);
                }

            } else if (Integer.parseInt(args[2]) == 4) {
                //Updating Admission Payment
                Scanner scanner = new Scanner(System.in);
                System.out.print("Enter Admission Number: ");
                int admissionNum = scanner.nextInt();

                Scanner scanner2 = new Scanner(System.in);
                System.out.print("Enter the new total payment: ");
                int newTotal = scanner.nextInt();

                String query = "UPDATE ADMISSION SET TOTALPAYMENT = ? WHERE ADMISSIONNUM = ?";

                PreparedStatement updateStatement = connection.prepareStatement(query);
                updateStatement.setDouble(1, newTotal);
                updateStatement.setInt(2, admissionNum);

                updateStatement.executeQuery();

//            updateStatement.close();

            } else {
                System.err.println("Options must be of [1, 2, 3, 4]");
            }

            connection.close();
        }
    }
}

