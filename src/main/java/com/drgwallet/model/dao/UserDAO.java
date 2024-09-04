package com.drgwallet.model.dao;

import com.drgwallet.model.mo.User;
import com.drgwallet.utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public void addUser(User user) throws SQLException {
        Connection connection = DatabaseConnection.getConnection();
        String query = "INSERT INTO user (username, password) VALUES (?, ?)";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPasswordHash());
            stmt.executeUpdate();
        }
    }

    public User getUserByUsername(String username) throws SQLException {
        Connection connection = DatabaseConnection.getConnection();
        String query = "SELECT * FROM user WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new User(rs.getInt("id"),rs.getString("username"), rs.getString("password_hash"), rs.getString("role"));
            }
        }
        return null;
    }

    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        Connection connection = DatabaseConnection.getConnection();
        String query = "SELECT * FROM user";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                users.add(new User(rs.getInt("id"),rs.getString("username"), rs.getString("password_hash"), rs.getString("role")));
            }
        }
        return users;
    }

    public void updateUser(User user) throws SQLException {
        Connection connection = DatabaseConnection.getConnection();
        String query = "UPDATE user SET username=?,password_hash=?,role=? WHERE id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPasswordHash());
            stmt.setString(3, user.getRole());
            ResultSet rs = stmt.executeQuery();

        }
    }
    public void deleteUser(User user) throws SQLException {
        Connection connection = DatabaseConnection.getConnection();
        String query = "DELETE FROM user WHERE username = ?";
        try (PreparedStatement stmt = connection.prepareStatement(query)) {
            stmt.setString(1, user.getUsername());
            stmt.executeUpdate();

        }

    }
}
