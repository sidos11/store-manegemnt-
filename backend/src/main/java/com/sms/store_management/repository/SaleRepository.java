package com.sms.store_management.repository;

import com.sms.store_management.model.Sale;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface SaleRepository extends JpaRepository<Sale, Long> {
    List<Sale> findByDate(String date);
}
