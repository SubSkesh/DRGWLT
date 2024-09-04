//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Buyer;
import com.drgwallet.utils.DatabaseConnection;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class BuyerDAOTest {
    private BuyerDAO buyerDAO;
    private Connection connection;

    BuyerDAOTest() {
    }

    @BeforeEach
    void setUp() throws SQLException {
        this.buyerDAO = new BuyerDAO();
        this.connection = DatabaseConnection.getConnection();
        this.clearDatabase();
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

    @Test
    void testAddAndGetBuyer() throws SQLException {
        Buyer buyer = new Buyer("TestBuyer");
        this.buyerDAO.addBuyer(buyer);
        Buyer retrievedBuyer = this.buyerDAO.getBuyerByName("TestBuyer");
        Assertions.assertNotNull(retrievedBuyer);
        Assertions.assertEquals("TestBuyer", retrievedBuyer.getNome());
    }

    @Test
    void testGetAllBuyers() throws SQLException {
        Buyer buyer = new Buyer("TestBuyer");
        this.buyerDAO.addBuyer(buyer);
        List<Buyer> buyers = this.buyerDAO.getAllBuyers();
        Assertions.assertNotNull(buyers);
        Assertions.assertFalse(buyers.isEmpty(), "La lista dei buyers non dovrebbe essere vuota");
    }

    @Test
    void testUpdateBuyer() throws SQLException {
        Buyer buyer = new Buyer("TestBuyer");
        this.buyerDAO.addBuyer(buyer);

        // Recupera il buyer aggiunto
        Buyer retrievedBuyer = this.buyerDAO.getBuyerByName("TestBuyer");
        Assertions.assertNotNull(retrievedBuyer, "Buyer should not be null after addition");
        System.out.println("Buyer added: " + retrievedBuyer.getNome());

        // Aggiorna il nome del buyer
        String oldName = retrievedBuyer.getNome(); // Memorizza il vecchio nome
        buyer.setNome("UpdatedBuyer"); // Imposta il nuovo nome
        this.buyerDAO.updateBuyer(buyer, oldName); // Passa sia il nuovo nome che il vecchio nome

        // Verifica l'aggiornamento
        Buyer updatedBuyer = this.buyerDAO.getBuyerByName("UpdatedBuyer");
        Assertions.assertNotNull(updatedBuyer, "Updated Buyer should not be null");
        Assertions.assertEquals("UpdatedBuyer", updatedBuyer.getNome());
        System.out.println("Buyer updated to: " + updatedBuyer.getNome());
    }



    @Test
    void testDeleteBuyer() throws SQLException {
        Buyer buyer = new Buyer("TestBuyerToDelete");
        this.buyerDAO.addBuyer(buyer);
        this.buyerDAO.deleteBuyer("TestBuyerToDelete");
        Buyer deletedBuyer = this.buyerDAO.getBuyerByName("TestBuyerToDelete");
        Assertions.assertNull(deletedBuyer);
    }
}
