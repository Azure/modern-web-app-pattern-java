package com.contoso.cams.support;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.stream.function.StreamBridge;

import com.contoso.cams.protobuf.email.v1.EmailRequest;

public class SupportGuideQueueSender implements SupportGuideSender {

    private static final Logger log = LoggerFactory.getLogger(SupportGuideDemoQueueSender.class);
    private static final String EMAIL_REQUEST_QUEUE = "produceemailrequest-out-0";

    private final StreamBridge streamBridge;

    public SupportGuideQueueSender(StreamBridge streamBridge) {
        this.streamBridge = streamBridge;
    }

    @Override
    public void send(String to, String guideUrl, Long requestId) {
        EmailRequest emailRequest = EmailRequest.newBuilder()
                .setRequestId(requestId)
                .setEmailAddress(to)
                .setUrlToManual(guideUrl)
                .build();

        log.info("EmailRequest: {}", emailRequest);

        streamBridge.send(EMAIL_REQUEST_QUEUE, emailRequest);

        log.info("Message sent to the queue");
    }
}