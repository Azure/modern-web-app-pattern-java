package com.contoso.cams;

import java.util.function.Consumer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.messaging.Message;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import nz.net.ultraq.thymeleaf.layoutdialect.LayoutDialect;

@SpringBootApplication
@EnableCaching
public class CamsApplication {

    private static final Logger log = LoggerFactory.getLogger(CamsApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(CamsApplication.class, args);
	}

	@Bean
	public LayoutDialect layoutDialect() {
		return new LayoutDialect();
	}

    @ControllerAdvice
    public class ExceptionHandlerControllerAdvice extends ResponseEntityExceptionHandler {
        private static final Logger log = LoggerFactory.getLogger(ExceptionHandlerControllerAdvice.class);

        @ExceptionHandler(AccessDeniedException.class)
        public ProblemDetail exceptionHandler(Exception ex) {
            log.error("Access Denied error", ex);
            ProblemDetail pd = ProblemDetail.forStatusAndDetail(HttpStatus.FORBIDDEN, "You do not have permission to access this resource.");
            return pd;
        }
    }

    @Bean
    Consumer<Message<String>> consumeEmailResponse() {
        return message -> {
            log.info("Received message: {}", message.getPayload());
        };
    }
}
