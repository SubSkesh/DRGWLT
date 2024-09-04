package com.drgwallet;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class MainApp extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        // Carica il file FXML
        Parent root = FXMLLoader.load(getClass().getResource("/fxml/main_view.fxml"));

        // Imposta la scena
        Scene scene = new Scene(root);

        // Configura la finestra principale
        primaryStage.setTitle("Drug Wallet Application");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
