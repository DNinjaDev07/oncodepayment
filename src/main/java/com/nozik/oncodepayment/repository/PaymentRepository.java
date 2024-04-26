package com.nozik.oncodepayment.repository;

import com.nozik.oncodepayment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {

}
