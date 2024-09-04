package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Deal;
import com.drgwallet.utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DealDAO {

    public void addDeal(Deal deal) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(
                     "INSERT INTO deal (price, grams, nome_drug, nome_buyer, debt, data) VALUES (?, ?, ?, ?, ?, ?)",
                     Statement.RETURN_GENERATED_KEYS)) {

            ps.setDouble(1, deal.getPrice());
            ps.setDouble(2, deal.getGrams());
            ps.setString(3, deal.getNomeDrug());
            ps.setString(4, deal.getNomeBuyer());
            ps.setBoolean(5, deal.isDebt());
            ps.setDate(6, new java.sql.Date(deal.getData().getTime()));

            // Esegui l'inserimento
            ps.executeUpdate();

            // Recupera l'ID generato automaticamente
            ResultSet generatedKeys = ps.getGeneratedKeys();
            if (generatedKeys.next()) {
                deal.setId(generatedKeys.getInt(1));
            }
        }
    }


    public Deal getDealById(int id) throws SQLException {
        Deal deal = null;
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM deal WHERE id = ?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                // Usa rs.getDate() che restituisce un oggetto java.sql.Date
                deal = new Deal(rs.getInt("id"), rs.getDouble("price"), rs.getDouble("grams"),
                        rs.getString("nome_drug"), rs.getString("nome_buyer"),
                        rs.getBoolean("debt"), rs.getDate("data"));
            }
        }
        return deal;
    }

    public List<Deal> getAllDeals() throws SQLException {
        List<Deal> deals = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM deal")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                deals.add(new Deal(rs.getDouble("price"), rs.getDouble("grams"), rs.getString("nome_drug"), rs.getString("nome_buyer"), rs.getBoolean("debt"), rs.getDate("data")));
            }
        }
        return deals;
    }

    public void updateDeal(Deal deal) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("UPDATE deal SET price = ?, grams = ?, nome_drug = ?, nome_buyer = ?, debt = ?, data = ? WHERE id = ?")) {
            ps.setDouble(1, deal.getPrice());
            ps.setDouble(2, deal.getGrams());
            ps.setString(3, deal.getNomeDrug());
            ps.setString(4, deal.getNomeBuyer());
            ps.setBoolean(5, deal.isDebt());

            // Conversione da java.util.Date a java.sql.Date
            ps.setDate(6, new java.sql.Date(deal.getData().getTime()));
            ps.setInt(7, deal.getId());
            ps.executeUpdate();
        }
    }

    public void deleteDeal(int id) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("DELETE FROM deal WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
