package com.sms.store_management.controller;

import com.sms.store_management.model.Sale;
import com.sms.store_management.repository.SaleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController

@RequestMapping("/api/sales")
@CrossOrigin(origins = "*", allowedHeaders = "*", exposedHeaders = "Authorization")
public class SaleController {

    @Autowired
    private SaleRepository repository;

    @GetMapping
    public List<Sale> getAll() {
        return repository.findAll();
    }

    @PostMapping
    public ResponseEntity<Sale> add(@RequestBody Sale sale) {
        return ResponseEntity.status(HttpStatus.CREATED).body(repository.save(sale));
    }

    @GetMapping("/date/{date}")
    public List<Sale> getByDate(@PathVariable String date) {
        return repository.findByDate(date);
    }
}
