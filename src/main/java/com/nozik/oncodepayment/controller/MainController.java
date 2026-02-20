package com.nozik.oncodepayment.controller;

import com.nozik.oncodepayment.entity.Payment;
import com.nozik.oncodepayment.exceptions.PaymentNotFoundException;
import com.nozik.oncodepayment.repository.PaymentRepository;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/oncode")
public class MainController {

    private final PaymentRepository paymentRepository;

    public MainController(PaymentRepository paymentRepository) {
        this.paymentRepository = paymentRepository;
    }

    @GetMapping("/getpayments")
    public List<Payment> getPayments() {
        return paymentRepository.findAll();
    }

    @PostMapping("/addpayment")
    public ResponseEntity<Payment> newPayment(@Valid @RequestBody Payment newPayment) {
        Payment saved = paymentRepository.save(newPayment);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @GetMapping("/getpayment/{id}")
    public ResponseEntity<Payment> getPayment(@PathVariable int id) {
        return paymentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new PaymentNotFoundException(id));
    }

    @PutMapping("/updatepayment/{id}")
    public ResponseEntity<Payment> updatePayment(@Valid @RequestBody Payment updatePayment, @PathVariable int id) {
        Payment payment = paymentRepository.findById(id)
                .orElseThrow(() -> new PaymentNotFoundException(id));

        payment.setAmount(updatePayment.getAmount());
        payment.setFromAccount(updatePayment.getFromAccount());
        payment.setToAccount(updatePayment.getToAccount());
        paymentRepository.save(payment);
        return ResponseEntity.ok(payment);
    }

    @DeleteMapping("/deletepayment/{id}")
    public ResponseEntity<Void> deletePayment(@PathVariable int id) {
        if (paymentRepository.existsById(id)) {
            paymentRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            throw new PaymentNotFoundException(id);
        }
    }
}
