package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Buyer;
import com.drgwallet.utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BuyerDAO {
    public void addBuyer(Buyer buyer) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("INSERT INTO buyer (nome) VALUES (?)")) {
            ps.setString(1, buyer.getNome());
            ps.executeUpdate();
        }
    }

    public Buyer getBuyerByName(String nome) throws SQLException {
        Buyer buyer = null;
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM buyer WHERE nome = ?")) {
            ps.setString(1, nome);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                buyer = new Buyer(rs.getString("nome"));
            }
        }
        return buyer;
    }

    public List<Buyer> getAllBuyers() throws SQLException {
        List<Buyer> buyers = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM buyer")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                buyers.add(new Buyer(rs.getString("nome")));
            }
        }
        return buyers;
    }

    public void updateBuyer(Buyer buyer, String oldName) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("UPDATE buyer SET nome = ? WHERE nome = ?")) {
            ps.setString(1, buyer.getNome()); // Nuovo nome
            ps.setString(2, oldName); // Vecchio nome (criterio di ricerca)
            ps.executeUpdate();
        }
    }

    public void deleteBuyer(String nome) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("DELETE FROM buyer WHERE nome = ?")) {
            ps.setString(1, nome);
            ps.executeUpdate();
        }
    }
}
