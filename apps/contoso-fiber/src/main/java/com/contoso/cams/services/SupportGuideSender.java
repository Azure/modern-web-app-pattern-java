package com.contoso.cams.services;

public interface SupportGuideSender {
    void send(String to, String guideUrl, Long requestId);
}

