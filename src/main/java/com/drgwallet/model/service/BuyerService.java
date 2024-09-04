//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.service;

import com.drgwallet.model.dao.BuyerDAO;
import com.drgwallet.model.mo.Buyer;
import java.sql.SQLException;

public class BuyerService {
    private BuyerDAO buyerDAO = new BuyerDAO();

    public BuyerService() {
    }

    public void addBuyer(String nome) throws SQLException {
        Buyer buyer = new Buyer(nome);
        this.buyerDAO.addBuyer(buyer);
    }

    public Buyer getBuyerByName(String nome) throws SQLException {
        return this.buyerDAO.getBuyerByName(nome);
    }
}
