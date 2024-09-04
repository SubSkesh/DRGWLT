//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.service;

import com.drgwallet.model.dao.DrugDAO;
import com.drgwallet.model.mo.Drug;
import java.sql.SQLException;

public class DrugService {
    private DrugDAO drugDAO = new DrugDAO();

    public DrugService() {
    }

    public void addDrug(String nome, double priceAvg) throws SQLException {
        Drug drug = new Drug(nome, priceAvg);
        this.drugDAO.addDrug(drug);
    }

    public Drug getDrugByNome(String nome) throws SQLException {
        return this.drugDAO.getDrugByName(nome);
    }
}
