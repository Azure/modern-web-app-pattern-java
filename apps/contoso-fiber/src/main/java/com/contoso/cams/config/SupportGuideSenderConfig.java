package com.contoso.cams.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.cloud.stream.function.StreamBridge;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.contoso.cams.services.SupportGuideDemoQueueSender;
import com.contoso.cams.services.SupportGuideEmailSender;
import com.contoso.cams.services.SupportGuideQueueSender;
import com.contoso.cams.services.SupportGuideSender;

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
