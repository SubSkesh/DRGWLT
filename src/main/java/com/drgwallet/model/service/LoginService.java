//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.service;

import com.drgwallet.model.dao.UserDAO;
import com.drgwallet.model.mo.User;
import java.sql.SQLException;

public class LoginService {
    private UserDAO userDAO = new UserDAO();

    public LoginService() {
    }

    public boolean authenticate(String username, String password) throws SQLException {
        User user = this.userDAO.getUserByUsername(username);
        return user != null ? password.equals(user.getPasswordHash()) : false;
    }
}
