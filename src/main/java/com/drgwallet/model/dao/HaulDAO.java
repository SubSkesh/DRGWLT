package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Haul;
import com.drgwallet.utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HaulDAO {

    public void addHaul(Haul haul) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("INSERT INTO haul (nome,price,data_buy,grams_bought,cashmade,gramsold, nome_drug) VALUES (?, ?)")) {
            ps.setString(1, haul.getNome());
            ps.setDouble(2, haul.getPrice());
            ps.setDate(3, new java.sql.Date(haul.getDataBuy().getTime()));
            ps.setDouble(4, haul.getGramsBought());
            ps.setDouble(5,haul.getCashMade());
            ps.setDouble(6,haul.getGramsSold());
            ps.setString(7,haul.getNomeDr());
            ps.executeUpdate();
        }
    }

    public Haul getHaulByNome(String nome) throws SQLException {
        Haul haul = null;
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM haul WHERE nome = ?")) {
            ps.setString(1, nome);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                haul = new Haul(rs.getString("nome"), rs.getString("nome_dr"),rs.getDouble("price"),rs.getDate("data_buy"),rs.getDouble("grams_bought"),rs.getDouble("cashmade"),rs.getDouble("gramsold") );
            }
        }
        return haul;
    }

    public List<Haul> getAllHauls() throws SQLException {
        List<Haul> hauls = new ArrayList<>();
        Haul haul= null;
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM haul")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                haul = new Haul(rs.getString("nome"), rs.getString("nome_dr"), rs.getDouble("price"), rs.getDate("data_buy"), rs.getDouble("grams_bought"), rs.getDouble("cashmade"), rs.getDouble("gramsold"));
            }
        }
        return hauls;
    }

    public void updateHaul(Haul haul) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("UPDATE haul SET nome = ?, nome_dr = ?, price = ?, data_buy = ?, grams_bought = ?, cashmade = ?, grams_sold = ? WHERE nome = ?")) {
            ps.setString(1, haul.getNome());
            ps.setString(2, haul.getNomeDr());
            ps.setDouble(3, haul.getPrice());
            ps.setDate(4,haul.getDataBuy());
            ps.setDouble(5,haul.getGramsBought());
            ps.setDouble(6,haul.getCashMade());
            ps.setDouble(7,haul.getGramsSold());

            ps.executeUpdate();
        }
    }

    public void deleteHaul(String nome) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("DELETE FROM haul WHERE nome = ?")) {
            ps.setString(1, nome);
            ps.executeUpdate();
        }
    }
}
