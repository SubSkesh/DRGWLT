//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.service;

import com.drgwallet.model.dao.HaulDAO;
import com.drgwallet.model.mo.Haul;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

public class HaulService {
    private HaulDAO haulDAO = new HaulDAO();

    public HaulService() {
    }

    public void addHaul(String nome, String nomeDr, double price, Date dataBuy, double gramsBought, double cashMade, double gramsSold) throws SQLException {
        if (this.haulDAO.getHaulByNome(nome) != null) {
            throw new IllegalArgumentException("Un haul con questo nome esiste già.");
        } else {
            Haul haul = new Haul(nome, nomeDr, price, dataBuy, gramsBought, cashMade, gramsSold);
            this.haulDAO.addHaul(haul);
        }
    }

    public Haul getHaulByNome(String nome) throws SQLException {
        return this.haulDAO.getHaulByNome(nome);
    }

    public List<Haul> getAllHauls() throws SQLException {
        return this.haulDAO.getAllHauls();
    }

    public void updateHaul(String nome, String nomeDr, double newPrice, Date newDateBuy, double newGramsBought, double newCashMade, double newGramsSold) throws SQLException {
        Haul haul = this.haulDAO.getHaulByNome(nome);
        if (haul == null) {
            throw new IllegalArgumentException("Haul non trovato con nome: " + nome);
        } else {
            haul.setNomeDr(nomeDr);
            haul.setPrice(newPrice);
            haul.setDataBuy(newDateBuy);
            haul.setGramsBought(newGramsBought);
            haul.setCashMade(newCashMade);
            haul.setGramsSold(newGramsSold);
            this.haulDAO.updateHaul(haul);
        }
    }

    public void deleteHaul(String nome) throws SQLException {
        Haul haul = this.haulDAO.getHaulByNome(nome);
        if (haul == null) {
            throw new IllegalArgumentException("Haul non trovato con nome: " + nome);
        } else {
            this.haulDAO.deleteHaul(nome);
        }
    }
}
