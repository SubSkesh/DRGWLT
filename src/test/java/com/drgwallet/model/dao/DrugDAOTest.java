//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.dao;

import com.drgwallet.model.mo.Drug;
import java.sql.SQLException;
import java.util.List;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class DrugDAOTest {
    private DrugDAO drugDAO;

    DrugDAOTest() {
    }

    @BeforeEach
    void setUp() {
        this.drugDAO = new DrugDAO();
    }

    @Test
    void testAddAndGetDrug() throws SQLException {
        Drug drug = new Drug("TestDrug", 50.0);
        this.drugDAO.addDrug(drug);
        Drug retrievedDrug = this.drugDAO.getDrugByName("TestDrug");
        Assertions.assertNotNull(retrievedDrug);
        Assertions.assertEquals("TestDrug", retrievedDrug.getNome());
        Assertions.assertEquals(50.0, retrievedDrug.getPriceAvg());
    }

    @Test
    void testGetAllDrugs() throws SQLException {
        List<Drug> drugs = this.drugDAO.getAllDrugs();
        Assertions.assertNotNull(drugs);
        Assertions.assertFalse(drugs.isEmpty());
    }

    @Test
    void testUpdateDrug() throws SQLException {
        Drug drug = new Drug("TestDrug", 50.0);
        this.drugDAO.addDrug(drug);
        drug.setPriceAvg(75.0);
        this.drugDAO.updateDrug(drug);
        Drug updatedDrug = this.drugDAO.getDrugByName("TestDrug");
        Assertions.assertNotNull(updatedDrug);
        Assertions.assertEquals(75.0, updatedDrug.getPriceAvg());
    }

    @Test
    void testDeleteDrug() throws SQLException {
        Drug drug = new Drug("TestDrugToDelete", 50.0);
        this.drugDAO.addDrug(drug);
        this.drugDAO.deleteDrug("TestDrugToDelete");
        Drug deletedDrug = this.drugDAO.getDrugByName("TestDrugToDelete");
        Assertions.assertNull(deletedDrug);
    }
}
