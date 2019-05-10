import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;

public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!

        try {
            connection = DriverManager.getConnection(url, username, password);
            return true;
        } catch(SQLException se) {
            return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try {
            connection.close();
            return true;
        } catch (SQLException se) {
            return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        List<Integer> elections = new ArrayList<>();
        List<Integer> cabinets = new ArrayList<>();
        String querystring = "SELECT election.id AS e_id, cabinet.id AS c_id " + "FROM election, country, cabinet " + "WHERE election.country_id = country.id AND " + "election.id = cabinet.election_id AND " + "country.name = ? " + "ORDER BY election.e_date DESC;";

        try {
            PreparedStatement ps = connection.prepareStatement(querystring);
            ps.setString(1, countryName);
            
            ResultSet result = ps.executeQuery();
            while (result.next()) {
                elections.add(result.getInt("e_id"));
                cabinets.add(result.getInt("c_id"));
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
        }
        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        List<Integer> similarpolitician = new ArrayList<>();
        String querystring1 = "SELECT description, comment " + "FROM politician_president " + "WHERE id = ?;";
        String querystring2 = "SELECT id, description, comment " + "FROM politician_president " + "WHERE id <> ?;";

        try {
            // information about given president
            PreparedStatement ps1 = connection.prepareStatement(querystring1);
            ps1.setInt(1, politicianName);
            ResultSet result1 = ps1.executeQuery();
            result1.next();
            String co = result1.getString("comment");
            String de = result1.getString("description");

            // information about all other presidents
            PreparedStatement ps2 = connection.prepareStatement(querystring2);
            ps2.setInt(1, politicianName);
            ResultSet result2 = ps2.executeQuery();
            
            //compare similarities
            while (result2.next()) {
                String co2 = result2.getString("comment");
                String de2 = result2.getString("description");
                double sim1 = similarity(de, de2);
                double sim2 = similarity(co, co2);
                                        
                if ((sim1 + sim2) >= threshold){
                    similarpolitician.add(result2.getInt("id"));
                }
            }

        } catch (SQLException se) {
            System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
        }
        return similarpolitician;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

