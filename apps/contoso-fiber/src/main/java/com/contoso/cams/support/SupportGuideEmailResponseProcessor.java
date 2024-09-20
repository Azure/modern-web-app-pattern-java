package com.contoso.cams.support;

import java.util.function.Consumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.Message;

import com.azure.spring.messaging.checkpoint.Checkpointer;
import com.contoso.cams.model.ActivityType;
import com.contoso.cams.protobuf.email.v1.EmailResponse;
import com.google.protobuf.InvalidProtocolBufferException;

import lombok.AllArgsConstructor;

import static com.azure.spring.messaging.AzureHeaders.CHECKPOINTER;

@Configuration
@AllArgsConstructor
public class SupportGuideEmailResponseProcessor {

    private static final Logger log = LoggerFactory.getLogger(SupportGuideEmailResponseProcessor.class);

    private final SupportCaseService supportCaseService;

    @Bean
    Consumer<Message<byte[]>> consumeemailresponse() {
        return message -> {
            Checkpointer checkpointer = (Checkpointer) message.getHeaders().get(CHECKPOINTER);
            log.info("Received message: {}", new String(message.getPayload()));

            EmailResponse emailResponse = parseMessage(message);

            NewSupportCaseActivityRequest newSupportCaseActivityRequest = new NewSupportCaseActivityRequest(
                emailResponse.getRequestId(),
                emailResponse.getMessage(),
                ActivityType.NOTE
            );

            supportCaseService.createSupportCaseActivity(newSupportCaseActivityRequest);

            // Checkpoint after processing the message
            checkpointer.success()
                .doOnSuccess(s -> log.info("Message '{}' successfully checkpointed", new String(message.getPayload())))
                .doOnError(e -> log.error("Exception found", e))
                .block();
        };
    }

    private EmailResponse parseMessage(Message<byte[]> message) {
        try {
            EmailResponse emailResponse = EmailResponse.parseFrom(message.getPayload());
            return emailResponse;
        } catch (InvalidProtocolBufferException e) {
            log.error("Error parsing email request message", e);
            throw new RuntimeException("Error parsing email request message", e);
        }
    }
}
