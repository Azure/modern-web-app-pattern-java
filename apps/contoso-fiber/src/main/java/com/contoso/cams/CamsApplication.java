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

import com.azure.spring.messaging.checkpoint.Checkpointer;

import static com.azure.spring.messaging.AzureHeaders.CHECKPOINTER;

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
    Consumer<Message<String>> consumeemailresponse() {
        return message -> {
            Checkpointer checkpointer = (Checkpointer) message.getHeaders().get(CHECKPOINTER);
            log.info("Received message: {}", message.getPayload());

            // Checkpoint after processing the message
            checkpointer.success()
                .doOnSuccess(s -> log.info("Message '{}' successfully checkpointed", message.getPayload()))
                .doOnError(e -> log.error("Exception found", e))
                .block();
        };
    }
}
