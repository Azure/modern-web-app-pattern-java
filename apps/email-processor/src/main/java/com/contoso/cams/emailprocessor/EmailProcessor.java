package com.contoso.cams.emailprocessor;

import java.util.function.Function;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.contoso.cams.protobuf.email.v1.EmailRequest;
import com.contoso.cams.protobuf.email.v1.EmailResponse;
import com.contoso.cams.protobuf.email.v1.EmailResponse.Status;
import com.google.protobuf.InvalidProtocolBufferException;

@Configuration
public class EmailProcessor {

    private static final Logger log = LoggerFactory.getLogger(EmailProcessor.class);

    @Bean
    Function<String, String> consume() {
        return message -> {

            log.info("New message received");

            try {
                EmailRequest emailRequest = EmailRequest.parseFrom(message.getBytes());
                log.info("EmailRequest: {}", emailRequest);

                EmailResponse emailResponse = EmailResponse.newBuilder()
                        .setEmailAddress(emailRequest.getEmailAddress())
                        .setUrlToManual(emailRequest.getUrlToManual())
                        .setStatus(Status.SUCCESS)
                        .build();

                return emailResponse.toString();

            } catch (InvalidProtocolBufferException e) {
                throw new RuntimeException("Error parsing email request message", e);
            }
        };
    }
}