//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Haul;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class HaulDAOTest {
    private HaulDAO haulDAO;

    HaulDAOTest() {
    }

    @BeforeEach
    void setUp() {
        this.haulDAO = new HaulDAO();
    }

    @Test
    void testAddAndGetHaul() throws SQLException {
        Haul haul = new Haul("TestHaul", "TestDrug", 100.0, new Date(), 500.0, 200.0, 300.0);
        this.haulDAO.addHaul(haul);
        Haul retrievedHaul = this.haulDAO.getHaulByNome("TestHaul");
        Assertions.assertNotNull(retrievedHaul);
        Assertions.assertEquals("TestHaul", retrievedHaul.getNome());
        Assertions.assertEquals(100.0, retrievedHaul.getPrice());
    }

    @Test
    void testGetAllHauls() throws SQLException {
        List<Haul> hauls = this.haulDAO.getAllHauls();
        Assertions.assertNotNull(hauls);
        Assertions.assertFalse(hauls.isEmpty());
    }

    @Test
    void testUpdateHaul() throws SQLException {
        Haul haul = new Haul("TestHaul", "TestDrug", 100.0, new Date(), 500.0, 200.0, 300.0);
        this.haulDAO.addHaul(haul);
        haul.setPrice(120.0);
        haul.setGramsSold(350.0);
        this.haulDAO.updateHaul(haul);
        Haul updatedHaul = this.haulDAO.getHaulByNome("TestHaul");
        Assertions.assertNotNull(updatedHaul);
        Assertions.assertEquals(120.0, updatedHaul.getPrice());
        Assertions.assertEquals(350.0, updatedHaul.getGramsSold());
    }

    @Test
    void testDeleteHaul() throws SQLException {
        Haul haul = new Haul("TestHaulToDelete", "TestDrug", 100.0, new Date(), 500.0, 200.0, 300.0);
        this.haulDAO.addHaul(haul);
        this.haulDAO.deleteHaul("TestHaulToDelete");
        Haul deletedHaul = this.haulDAO.getHaulByNome("TestHaulToDelete");
        Assertions.assertNull(deletedHaul);
    }
}
