package com.contoso.cams.supportguide;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.InputStreamSource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.io.WritableResource;
import org.springframework.stereotype.Service;
import org.springframework.util.FileCopyUtils;

import com.contoso.cams.model.SupportGuideRepository;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@AllArgsConstructor
@Slf4j
public class SupportGuideService {

    private static final String BLOB_RESOURCE_PATTERN = "azure-blob://%s/%s";

    private final SupportGuideRepository guideRepository;
    private final ResourceLoader resourceLoader;

    @Value("${spring.cloud.azure.storage.blob.container-name}")
    private final String blobContainerName;

    public List<SupportGuideDto> getSupportGuides() {
        return guideRepository.findAll().stream()
            .map(guide -> new SupportGuideDto(
                guide.getId(),
                guide.getName(),
                guide.getDescription(),
                guide.getUrl()))
            .collect(Collectors.toList());
    }

    public void uploadGuide(String fileName, InputStreamSource guideInputStream) throws IOException {
        var location = String.format(BLOB_RESOURCE_PATTERN, blobContainerName, fileName);
        log.info("Saving guide: {} to {}", fileName, location);

        Resource resource = resourceLoader.getResource(location);
        try (OutputStream outputStream = ((WritableResource) resource).getOutputStream();
             InputStream inputStream = guideInputStream.getInputStream()) {
            FileCopyUtils.copy(inputStream, outputStream);
        }

        //guideRepository.save(guide.toEntity());
    }
}
