package com.nozik.oncodepayment;

import com.nozik.oncodepayment.entity.Payment;
//import com.nozik.oncodepayment.repository.PaymentMongoRepository;
import com.nozik.oncodepayment.repository.PaymentRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Random;
import java.util.random.RandomGenerator;

@Slf4j
@Configuration
public class InitialDatabaseLoad {

    @Bean
    CommandLineRunner initDatabase(PaymentRepository repository) {

        return args -> {
            Random random = new Random();
            int minIterations = 4;
            int maxIterations = 10;
            int numberOfIterations = random.nextInt(maxIterations - minIterations + 1) + minIterations;

            for (int i=0; i< numberOfIterations; i++){
                log.info("Preloading " + repository.save(new Payment(Math.round(random.nextDouble() * 1000 * 100.0) / 100.0,random.nextInt(900000000) + 100000000 , random.nextInt(900000000) + 100000000)));
            }

        };
    }

}
