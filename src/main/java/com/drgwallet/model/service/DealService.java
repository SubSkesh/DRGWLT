//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.service;

import com.drgwallet.model.dao.DealDAO;
import com.drgwallet.model.mo.Deal;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

public class DealService {
    private DealDAO dealDAO = new DealDAO();

    public DealService() {
    }

    public void addDeal(double price, double grams, String nomeDrug, String nomeBuyer, boolean debt, Date data) throws SQLException {
        Deal deal = new Deal(price, grams, nomeDrug, nomeBuyer, debt, data);
        this.dealDAO.addDeal(deal);
    }

    public Deal getDealById(int id) throws SQLException {
        return this.dealDAO.getDealById(id);
    }

    public List<Deal> getAllDeals() throws SQLException {
        return this.dealDAO.getAllDeals();
    }
}
