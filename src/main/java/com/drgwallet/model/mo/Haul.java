//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.mo;

import java.util.Date;

public class Haul {
    private String nome;
    private String nomeDr;
    private double price;
    private Date dataBuy;
    private double gramsBought;
    private double cashMade;
    private double gramsSold;

    public Haul() {
    }

    public Haul(String nome, String nomeDr, double price, Date dataBuy, double gramsBought, double cashMade, double gramsSold) {
        this.nome = nome;
        this.nomeDr = nomeDr;
        this.price = price;
        this.dataBuy = dataBuy;
        this.gramsBought = gramsBought;
        this.cashMade = cashMade;
        this.gramsSold = gramsSold;
    }

    public String getNome() {
        return this.nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getNomeDr() {
        return this.nomeDr;
    }

    public void setNomeDr(String nomeDr) {
        this.nomeDr = nomeDr;
    }

    public double getPrice() {
        return this.price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public java.sql.Date getDataBuy() {
        return (java.sql.Date) this.dataBuy;
    }

    public void setDataBuy(Date dataBuy) {
        this.dataBuy = dataBuy;
    }

    public double getGramsBought() {
        return this.gramsBought;
    }

    public void setGramsBought(double gramsBought) {
        this.gramsBought = gramsBought;
    }

    public double getCashMade() {
        return this.cashMade;
    }

    public void setCashMade(double cashMade) {
        this.cashMade = cashMade;
    }

    public double getGramsSold() {
        return this.gramsSold;
    }

    public void setGramsSold(double gramsSold) {
        this.gramsSold = gramsSold;
    }
}
