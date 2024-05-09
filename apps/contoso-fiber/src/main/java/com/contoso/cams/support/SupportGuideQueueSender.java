package com.contoso.cams.support;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.azure.messaging.servicebus.ServiceBusMessage;
import com.azure.messaging.servicebus.ServiceBusSenderClient;
import com.contoso.cams.protobuf.email.v1.EmailRequest;

public class SupportGuideQueueSender implements SupportGuideSender {

    private static final Logger log = LoggerFactory.getLogger(SupportGuideDemoQueueSender.class);
    private final ServiceBusSenderClient serviceBusSenderClient;

    public SupportGuideQueueSender(ServiceBusSenderClient serviceBusSenderClient) {
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

        serviceBusSenderClient.sendMessage(new ServiceBusMessage(emailRequest.toByteArray()));

        log.info("Message sent to the queue");
    }
}
