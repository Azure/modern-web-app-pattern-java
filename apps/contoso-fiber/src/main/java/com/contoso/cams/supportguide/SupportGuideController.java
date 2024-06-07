package com.contoso.cams.supportguide;

import java.io.IOException;
import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.web.bind.annotation.PostMapping;


@Controller
@AllArgsConstructor
@Slf4j
@RequestMapping(value = "/guides")
public class SupportGuideController {
    private final SupportGuideService guideService;

    @GetMapping("/list")
    @PreAuthorize("hasAnyAuthority('APPROLE_AccountManager')")
    public String listServiceGuides(Model model) {
        List<SupportGuideDto> serviceGuides = guideService.getSupportGuides();
        model.addAttribute("guides", serviceGuides);
        return "pages/guides/list";
    }

    @GetMapping("/upload")
    @PreAuthorize("hasAnyAuthority('APPROLE_AccountManager')")
    public String displayUploadGuideForm(Model model) {
        var uploadSupportGuide = new UploadSupportGuideRequest();
        model.addAttribute("uploadSupportGuide", uploadSupportGuide);
        return "pages/guides/upload";
    }

    @PostMapping("/upload")
    public String uploadGuide(Model model, @Valid @ModelAttribute("uploadSupportGuide") UploadSupportGuideRequest uploadSupportGuideRequest, BindingResult result) throws IOException {

        try {
            if (result.hasErrors()) {
                String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
                throw new IllegalArgumentException("Validation errors while uploading support guide - " + errorMessage);
            }

            guideService.uploadGuide(uploadSupportGuideRequest);

            return "redirect:/guides/list";
        } catch (IllegalArgumentException e) {
            log.error("Error while uploading a support guide", e);
            model.addAttribute("message", "Error while uploading a support guide - " + e.getMessage());
            return "pages/guides/upload";
        }
    }
}
