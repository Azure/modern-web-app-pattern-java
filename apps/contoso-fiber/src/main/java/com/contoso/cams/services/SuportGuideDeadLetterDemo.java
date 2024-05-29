package com.contoso.cams.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.stream.function.StreamBridge;

public class SuportGuideDeadLetterDemo implements SupportGuideSender {

    private static final Logger log = LoggerFactory.getLogger(SuportGuideDeadLetterDemo.class);
    private static final String EMAIL_REQUEST_QUEUE = "produceemailrequest-out-0";

    private final StreamBridge streamBridge;

    public SuportGuideDeadLetterDemo(StreamBridge streamBridge) {
        this.streamBridge = streamBridge;
    }

    @Override
    public void send(String to, String guideUrl, Long requestId) {
        final String bogusMessage = "This is a bogus message for request id " + requestId;

        log.info("EmailRequest: {}", bogusMessage);

        streamBridge.send(EMAIL_REQUEST_QUEUE, bogusMessage);

        log.info("Message sent to the queue");
    }
}
