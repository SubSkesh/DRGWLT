//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.drgwallet.model.dao;

import com.drgwallet.model.mo.User;
import java.sql.SQLException;
import java.util.List;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class UserDAOTest {
    private UserDAO userDAO;

    UserDAOTest() {
    }

    @BeforeEach
    void setUp() {
        this.userDAO = new UserDAO();
    }

    @Test
    void testAddAndGetUser() throws SQLException {
        User user = new User("TestUser", "password123", "admin");
        this.userDAO.addUser(user);
        User retrievedUser = this.userDAO.getUserByUsername("TestUser");
        Assertions.assertNotNull(retrievedUser);
        Assertions.assertEquals("TestUser", retrievedUser.getUsername());
    }

    @Test
    void testGetAllUsers() throws SQLException {
        List<User> users = this.userDAO.getAllUsers();
        Assertions.assertNotNull(users);
        Assertions.assertFalse(users.isEmpty());
    }

    @Test
    void testUpdateUser() throws SQLException {
        User user = new User("TestUser", "password123", "admin");
        this.userDAO.addUser(user);
        user.setPasswordHash("newpassword123");
        this.userDAO.updateUser(user);
        User updatedUser = this.userDAO.getUserByUsername("TestUser");
        Assertions.assertNotNull(updatedUser);
        Assertions.assertEquals("newpassword123", updatedUser.getPasswordHash());
    }

    @Test
    void testDeleteUser() throws SQLException {
        User user = new User("TestUserToDelete", "password123", "admin");
        this.userDAO.addUser(user);
        this.userDAO.deleteUser(user);
        User deletedUser = this.userDAO.getUserByUsername("TestUserToDelete");
        Assertions.assertNull(deletedUser);
    }
}
