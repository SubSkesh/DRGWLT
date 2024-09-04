//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.mo;

public class Drug {
    private String nome;
    private double priceAvg;

    public Drug() {
    }

    public Drug(String nome, double priceAvg) {
        this.nome = nome;
        this.priceAvg = priceAvg;
    }

    public String getNome() {
        return this.nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public double getPriceAvg() {
        return this.priceAvg;
    }

    public void setPriceAvg(double priceAvg) {
        this.priceAvg = priceAvg;
    }
}
