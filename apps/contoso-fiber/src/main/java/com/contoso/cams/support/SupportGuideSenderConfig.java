package com.contoso.cams.support;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.cloud.stream.function.StreamBridge;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SupportGuideSenderConfig {

    @Bean
    @ConditionalOnProperty(prefix = "contoso.suport-guide.request", name = "service", havingValue = "queue")
    SupportGuideSender supportGuideQueueSender(StreamBridge streamBridge) {
        return new SupportGuideQueueSender(streamBridge);
    }

    @Bean
    @ConditionalOnProperty(prefix = "contoso.suport-guide.request", name = "service", havingValue = "email")
    SupportGuideSender supportGuideEmailSender() {
        return new SupportGuideEmailSender();
    }

    @Bean
    @ConditionalOnProperty(prefix = "contoso.suport-guide.request", name = "service", havingValue = "demo")
    SupportGuideSender supportGuideDemoQueueSender(StreamBridge streamBridge) {
        return new SupportGuideDemoQueueSender(streamBridge);
    }
}
