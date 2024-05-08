package com.nozik.oncodepayment.exceptions;

public class PaymentNotFoundException extends RuntimeException{

    public PaymentNotFoundException(int id) {
        super("Unable to find payment for id = " + id);
    }

    public PaymentNotFoundException() {
        super();
    }
}
