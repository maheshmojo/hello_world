package com.example.hello_world;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ShoppingController {

    @GetMapping("/shopping")
    public String getShoppingList() {
        return "Eggs, Milk, Bread";
    }
}
