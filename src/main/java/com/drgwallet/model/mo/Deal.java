//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.mo;

import java.util.Date;
import java.util.Locale;



public class Deal {
    private int id;
    private double price;
    private double grams;
    private String nomeDrug;
    private String nomeBuyer;
    private boolean debt;
    private Date data;

    public Deal() {
    }

    public Deal(double price, double grams, String nomeDrug, String nomeBuyer, boolean debt, Date data) {
        this.price = price;
        this.grams = grams;
        this.nomeDrug = nomeDrug;
        this.nomeBuyer = nomeBuyer;
        this.debt = debt;
        this.data = data;
    }

    public Deal(int id, double price, double grams, String nomeDrug, String nomeBuyer, boolean debt, Date data) {
        this.id = id;
        this.price = price;
        this.grams = grams;
        this.nomeDrug = nomeDrug;
        this.nomeBuyer = nomeBuyer;
        this.debt = debt;
        this.data = data;
    }

    public int getId() {
        return this.id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public double getPrice() {
        return this.price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public double getGrams() {
        return this.grams;
    }

    public void setGrams(double grams) {
        this.grams = grams;
    }

    public String getNomeDrug() {
        return this.nomeDrug;
    }

    public void setNomeDrug(String nomeDrug) {
        this.nomeDrug = nomeDrug;
    }

    public String getNomeBuyer() {
        return this.nomeBuyer;
    }

    public void setNomeBuyer(String nomeBuyer) {
        this.nomeBuyer = nomeBuyer;
    }

    public boolean isDebt() {
        return this.debt;
    }

    public void setDebt(boolean debt) {
        this.debt = debt;
    }

    public Date getData() {
        // Se la data è di tipo java.util.Date, converti a java.sql.Date
        if (data instanceof java.util.Date) {
            return new java.sql.Date(data.getTime());
        }
        return (java.sql.Date) this.data; // Restituisce già java.sql.Date
    }

    public void setData(Date data) {
        this.data = data;
    }
}
