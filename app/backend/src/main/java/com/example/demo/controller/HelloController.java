package com.example.demo.controller;

import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class HelloController {

    @GetMapping("/hello")
    public Map<String,String> hello() {
        Map<String,String> resp = new HashMap<>();
        resp.put("message","Hello from Spring Boot backend");
        return resp;
    }
}