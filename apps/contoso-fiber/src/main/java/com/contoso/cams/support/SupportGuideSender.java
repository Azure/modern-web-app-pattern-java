package com.contoso.cams.support;

public interface SupportGuideSender {
    void send(String to, String guideUrl, Long requestId);
}

