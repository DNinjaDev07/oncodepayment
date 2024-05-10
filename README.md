# OncodePayment

OnCode payment recorder mimics a payment record solution. It is a REST API Project written in Java with the Spring framework with H2 in-memory database.

The technologies for development, testing and CI/CD include:

### Docker
Dockerfile is available in project and image has been built with:

`docker build -t oncode-payment:1.0 .`

![img.png](img.png)

Docker compose file has been created and can be run with:

`docker-compose -f compose.yaml up -d`

Docker container for oncode-paymentv1 running on machine.

![img_1.png](img_1.png)

### Postman
4 end points have been developed.
1. **GetAllPayments** - {{payurl}}/getpayments
   - HTTP Method - GET
2. **GetPaymentById** - {{payurl}}/getpayment/{{paymentId}}
   - HTTP Method - GET
3. **AddPayment** - {{payurl}}/addpayment
   - HTTP Method - POST
4. **UpdatePayment** - {{payurl}}/updatepayment/{{paymentId}}
   - HTTP Method - PUT
5. **DeletePaymentById** - {{payurl}}/deletepayment/{{paymentId}}
   - HTTP Method - DELETE

A postman collection [Postman Artifacts](/PostmanArtifacts) containing pre-request scripts and tests has been created to automate tests for the above endpoints.
This can be imported along with the environment for testing.

### Jenkins
### REST Assured
### Kubernetes
