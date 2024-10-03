package com.contoso.cams.serviceplan;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/*
 This utility class is used to simulate exceptions to test the CircuitBreaker and Retry implmentations
 based on the error rate set in the environment variable CONTOSO_RETRY_DEMO
 */

@Component
public class ServicePlanExceptionSimulator {

    private static int requestCount = 0;

    @Value("${contoso.retry.demo}")
    private String demo;

    /**
     * Check if exception should be thrown based on error rate
     */
    public void checkAndthrowExceptionIfEnabled() {
        int errorRate = getErrorRate();

        // if error rate = 0 then return
        if (errorRate == 0) {
            return;
        }
        if (requestCount++ % errorRate == 0) {
            throw new RuntimeException("Simulated exception calling ServicePlanService.getServicePlans()");
        }
    }

    /*
     * Get error rate from environment variable
     * 0 = no error (Default)
     * 1 = fail request every time
     * 2 = fail request every 2nd time
     */
    private int getErrorRate() {
        int errorRate = 0;
    
        if (!StringUtils.isEmpty(demo)) {
            errorRate = Integer.parseInt(demo);
        }
        return errorRate;
    }

}