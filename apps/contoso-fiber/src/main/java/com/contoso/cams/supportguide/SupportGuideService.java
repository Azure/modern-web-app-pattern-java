package com.contoso.cams.supportguide;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.contoso.cams.model.SupportGuideRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class SupportGuideService {

    private final SupportGuideRepository guideRepository;

    public List<SupportGuideDto> getSupportGuides() {
        return guideRepository.findAll().stream()
            .map(guide -> new SupportGuideDto(
                guide.getId(),
                guide.getName(),
                guide.getDescription(),
                guide.getUrl()))
            .collect(Collectors.toList());
    }
}
