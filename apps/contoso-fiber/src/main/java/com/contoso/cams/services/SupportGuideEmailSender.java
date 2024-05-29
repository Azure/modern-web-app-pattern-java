package com.contoso.cams.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SupportGuideEmailSender implements SupportGuideSender {

    private static final Logger log = LoggerFactory.getLogger(SupportGuideEmailSender.class);

    @Override
    public void send(String to, String guideUrl, Long requestId) {
        log.info("Sending guide to {} with url {} by email for request id {}", to, guideUrl, requestId);
    }
}
