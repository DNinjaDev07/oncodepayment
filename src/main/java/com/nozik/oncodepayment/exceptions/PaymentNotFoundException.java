package com.nozik.oncodepayment.exceptions;

public class PaymentNotFoundException extends RuntimeException{

    public PaymentNotFoundException(Long id) {
        super("Unable to find payment for id = " + id.toString());
    }

    public PaymentNotFoundException() {
        super();
    }
}
