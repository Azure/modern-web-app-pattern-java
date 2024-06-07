package com.contoso.cams.supportguide;

import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@Data
public class UploadSupportGuideRequest {
    @NotBlank(message = "Description is mandatory")
    private String description;

    @NotNull(message = "Guide file is mandatory")
    MultipartFile file;
}
