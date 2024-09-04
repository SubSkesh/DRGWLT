package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Drug;
import com.drgwallet.utils.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DrugDAO {

    public void addDrug(Drug drug) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("INSERT INTO drug (nome) VALUES (?)")) {
            ps.setString(1, drug.getNome());
            ps.executeUpdate();
        }
    }

    public Drug getDrugByName(String nome) throws SQLException {
        Drug drug = null;
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM drug WHERE nome = ?")) {
            ps.setString(1, nome);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                drug = new Drug(rs.getString("nome"),rs.getDouble("price_avg"));
            }
        }
        return drug;
    }

    public List<Drug> getAllDrugs() throws SQLException {
        List<Drug> drugs = new ArrayList<>();
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("SELECT * FROM drug")) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                drugs.add(new Drug(rs.getString("nome"),rs.getDouble("price_avg")));
            }
        }
        return drugs;
    }

    public void updateDrug(Drug drug) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("UPDATE drug SET nome = ?,price_avg = ? WHERE nome = ?")) {
            ps.setString(1, drug.getNome());
            ps.setDouble(2,drug.getPriceAvg());
            ps.setString(3, drug.getNome());
            ps.executeUpdate();
        }
    }

    public void deleteDrug(String nome) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement("DELETE FROM drug WHERE nome = ?")) {
            ps.setString(1, nome);
            ps.executeUpdate();
        }
    }
}
