package com.nozik.oncodepayment.exceptionhandler;

import com.nozik.oncodepayment.exceptions.PaymentNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@Component
@Slf4j
@ControllerAdvice
@Order(Ordered.HIGHEST_PRECEDENCE)
public class GeneralExceptionHandler {

    @ExceptionHandler(PaymentNotFoundException.class)
    public String paymentNotFoundHandler (PaymentNotFoundException ex) {
        log.error("PaymentNotFoundException ::: {}", ex);
        return ex.getMessage();
    }


}
