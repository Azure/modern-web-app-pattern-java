package com.contoso.cams.supportguide;

import java.io.IOException;
import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;


@Controller
@AllArgsConstructor
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
    public String displayUploadGuideForm() {
        return "pages/guides/upload";
    }

    @PostMapping("/upload")
    public String uploadGuide(@RequestParam("guide") MultipartFile file) throws IOException {

        guideService.uploadGuide(file.getOriginalFilename(), file);

        return "redirect:/guides/list";
    }
}
