package com.contoso.cams.support;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.azure.messaging.servicebus.ServiceBusMessage;
import com.azure.messaging.servicebus.ServiceBusSenderClient;
import com.contoso.cams.protobuf.email.v1.EmailRequest;

public class SupportGuideDemoQueueSender implements SupportGuideSender {

    private static final Logger log = LoggerFactory.getLogger(SupportGuideDemoQueueSender.class);
    private final ServiceBusSenderClient serviceBusSenderClient;

    public SupportGuideDemoQueueSender(ServiceBusSenderClient serviceBusSenderClient) {
        this.serviceBusSenderClient = serviceBusSenderClient;
    }

    @Override
    public void send(String to, String guideUrl, Long requestId) {
        EmailRequest emailRequest = EmailRequest.newBuilder()
                .setRequestId(requestId)
                .setEmailAddress(to)
                .setUrlToManual(guideUrl)
                .build();

        log.info("EmailRequest: {}", emailRequest);

        var message = emailRequest.toByteArray();

        for (int i = 0; i < 1_000; i++) {
            serviceBusSenderClient.sendMessage(new ServiceBusMessage(message));
        }

        log.info("Message sent to the queue");
    }
}
