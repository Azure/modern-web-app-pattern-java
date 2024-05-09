package com.contoso.cams.support;


import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.azure.messaging.servicebus.ServiceBusSenderClient;

@Configuration
public class SupportGuideSenderConfig {

    @Bean
    @ConditionalOnProperty(prefix = "contoso.suport-guide.request", name = "service", havingValue = "queue")
    SupportGuideSender supportGuideQueueSender(ServiceBusSenderClient serviceBusSenderClient) {
        return new SupportGuideQueueSender(serviceBusSenderClient);
    }

    @Bean
    @ConditionalOnProperty(prefix = "contoso.suport-guide.request", name = "service", havingValue = "email")
    SupportGuideSender supportGuideEmailSender() {
        return new SupportGuideEmailSender();
    }

    @Bean
    @ConditionalOnProperty(prefix = "contoso.suport-guide.request", name = "service", havingValue = "demo")
    SupportGuideSender supportGuideDemoQueueSender(ServiceBusSenderClient serviceBusSenderClient) {
        return new SupportGuideDemoQueueSender(serviceBusSenderClient);
    }
}
