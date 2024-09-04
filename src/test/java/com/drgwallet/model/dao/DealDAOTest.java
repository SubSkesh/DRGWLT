//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Deal;
import com.drgwallet.utils.DatabaseConnection;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class DealDAOTest {
    private DealDAO dealDAO;
    private Connection connection;

    DealDAOTest() {
    }

    @BeforeEach
    void setUp() throws SQLException {
        this.dealDAO = new DealDAO();
        this.connection = DatabaseConnection.getConnection();
        this.clearDatabase();
        this.insertTestDrug();
        this.insertTestBuyer();
    }

    @AfterEach
    void tearDown() throws SQLException {
        this.clearDatabase();
        if (this.connection != null) {
            this.connection.close();
        }

    }

    void clearDatabase() throws SQLException {
        Statement stmt = this.connection.createStatement();

        try {
            stmt.execute("DELETE FROM deal");
            stmt.execute("DELETE FROM drug");
            stmt.execute("DELETE FROM buyer");
        } catch (Throwable var5) {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (Throwable var4) {
                    var5.addSuppressed(var4);
                }
            }

            throw var5;
        }

        if (stmt != null) {
            stmt.close();
        }

    }

    void insertTestDrug() throws SQLException {
        Statement stmt = this.connection.createStatement();

        try {
            stmt.execute("INSERT INTO drug (nome) VALUES ('TestDrug')");
        } catch (Throwable var5) {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (Throwable var4) {
                    var5.addSuppressed(var4);
                }
            }

            throw var5;
        }

        if (stmt != null) {
            stmt.close();
        }

    }

    void insertTestBuyer() throws SQLException {
        Statement stmt = this.connection.createStatement();

        try {
            stmt.execute("INSERT INTO buyer (nome) VALUES ('TestBuyer')");
        } catch (Throwable var5) {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (Throwable var4) {
                    var5.addSuppressed(var4);
                }
            }

            throw var5;
        }

        if (stmt != null) {
            stmt.close();
        }

    }

    @Test
    void testAddAndGetDeal() throws SQLException {
        Deal deal = new Deal(100.0, 50.0, "TestDrug", "TestBuyer", false, new java.sql.Date(System.currentTimeMillis()));

        // Aggiungi il deal e recupera l'ID generato
        this.dealDAO.addDeal(deal);
        int generatedId = deal.getId();

        // Verifica che l'ID sia stato generato
        Assertions.assertTrue(generatedId > 0, "L'ID del deal dovrebbe essere maggiore di 0");

        // Recupera il deal dal database
        Deal retrievedDeal = this.dealDAO.getDealById(generatedId);

        // Assicurati che non sia null e verifica i valori
        Assertions.assertNotNull(retrievedDeal);
        Assertions.assertEquals("TestDrug", retrievedDeal.getNomeDrug());
        Assertions.assertEquals(100.0, retrievedDeal.getPrice());
    }


    @Test
    void testGetAllDeals() throws SQLException {
        Deal deal1 = new Deal(100.0, 50.0, "TestDrug", "TestBuyer", false, new Date());
        Deal deal2 = new Deal(200.0, 100.0, "TestDrug", "TestBuyer", true, new Date());
        this.dealDAO.addDeal(deal1);
        this.dealDAO.addDeal(deal2);
        List<Deal> deals = this.dealDAO.getAllDeals();
        Assertions.assertNotNull(deals);
        Assertions.assertTrue(deals.size() >= 2);
    }

    @Test
    void testUpdateDeal() throws SQLException {
        Deal deal = new Deal(100.0, 50.0, "TestDrug", "TestBuyer", false, new Date());
        this.dealDAO.addDeal(deal);
        int generatedId = deal.getId();
        deal.setPrice(150.0);
        this.dealDAO.updateDeal(deal);
        Deal updatedDeal = this.dealDAO.getDealById(generatedId);
        Assertions.assertNotNull(updatedDeal);
        Assertions.assertEquals(150.0, updatedDeal.getPrice());
    }

    @Test
    void testDeleteDeal() throws SQLException {
        Deal deal = new Deal(100.0, 50.0, "TestDrug", "TestBuyer", false, new Date());
        this.dealDAO.addDeal(deal);
        int generatedId = deal.getId();
        this.dealDAO.deleteDeal(generatedId);
        Deal deletedDeal = this.dealDAO.getDealById(generatedId);
        Assertions.assertNull(deletedDeal);
    }
}
