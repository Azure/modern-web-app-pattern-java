package com.contoso.cams.supportguide;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.AllArgsConstructor;

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
}
