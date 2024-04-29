package com.nozik.oncodepayment.controller;

import com.nozik.oncodepayment.entity.Payment;
import com.nozik.oncodepayment.exceptions.PaymentNotFoundException;
import com.nozik.oncodepayment.repository.PaymentRepository;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping("/oncode")
public class MainController {

    /*TO-DO: Fix data validation before saving to database
    REST Assured validation tests.
    */

    @Autowired
    private PaymentRepository paymentRepository;

    @GetMapping("/getpayments")
    public List<Payment> getPayments() throws IOException {
        return paymentRepository.findAll();
    }

    @PostMapping("/addpayment")
    public Payment newPayment(@Valid @RequestBody Payment newPayment) {
        return paymentRepository.save(newPayment);
    }

    @GetMapping("/getpayment/{id}")
    public ResponseEntity<Payment> getPayments(@PathVariable Long id) throws IOException {
//        return paymentRepository.findById(id)
//                .orElseThrow(() -> new PaymentNotFoundException(id));
        Optional<Payment> userOptional = paymentRepository.findById(id);
        return userOptional.map(ResponseEntity::ok).orElseThrow(() -> new PaymentNotFoundException(id));
    }

    @PutMapping("/updatepayment/{id}")
    public ResponseEntity<Payment> updatePayment(@Valid @RequestBody Payment updatePayment, @PathVariable Long id) {

        Optional<Payment> userOptional = paymentRepository.findById(id);
        if (userOptional.isPresent()) {
            Payment payment = userOptional.get();
            payment.setAmount(updatePayment.getAmount());
            payment.setFromAccount(updatePayment.getFromAccount());
            payment.setToAccount(updatePayment.getToAccount());
            paymentRepository.save(payment);
            return ResponseEntity.ok(payment);
        } else {
            throw new PaymentNotFoundException(id);
        }
    }

    @DeleteMapping("/deletepayment/{id}")
    public ResponseEntity<Void> deleteEmployee(@PathVariable Long id) {

        if (paymentRepository.existsById(id)) {
            paymentRepository.deleteById(id);
            return ResponseEntity.ok().build();
        } else {
            throw new PaymentNotFoundException(id);
        }
    }

}
