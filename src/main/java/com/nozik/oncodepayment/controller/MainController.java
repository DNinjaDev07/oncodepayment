package com.nozik.oncodepayment.controller;

import com.nozik.oncodepayment.entity.Payment;
import com.nozik.oncodepayment.exceptions.PaymentNotFoundException;
import com.nozik.oncodepayment.repository.PaymentRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.io.IOException;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/oncode")
public class MainController {

    /*TO-DO: Fix data validation on the endpoints.
    * Update endpoint is updating and creating new payment
    * Provide success message on delete endpoint
    * */

    @Autowired
    private PaymentRepository paymentRepository;

    @GetMapping("/getpayments")
    public List<Payment> getPayments() throws IOException {
        return paymentRepository.findAll();
    }

    @PostMapping("/addpayment")
    public Payment newPayment(@RequestBody Payment newPayment) {
        return paymentRepository.save(newPayment);
    }

    @GetMapping("/getpayment/{id}")
    public Payment getPayments(@PathVariable Long id) throws IOException {
        return paymentRepository.findById(id)
                .orElseThrow(() -> new PaymentNotFoundException(id));
    }

    @PutMapping("/updatepayment/{id}")
    public Payment updatePayment(@RequestBody Payment updatePayment, @PathVariable Long id) {

        return paymentRepository.findById(id)
                .map(payment -> {
                    payment.setAmount(updatePayment.getAmount());
                    payment.setFromAccount(updatePayment.getFromAccount());
                    payment.setToAccount(updatePayment.getToAccount());
                    return paymentRepository.save(updatePayment);
                })
                .orElseGet(() -> {
                    updatePayment.setId(id);
                    return paymentRepository.save(updatePayment);
                });
    }

    @DeleteMapping("/deletepayment/{id}")
    public void deleteEmployee(@PathVariable Long id) {
        paymentRepository.deleteById(id);
    }



}
