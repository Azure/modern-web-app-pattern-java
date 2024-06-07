package com.contoso.cams.model;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface SupportGuideRepository extends JpaRepository<SupportGuide, Long> {

    Optional<SupportGuide> findByName(String name);
}
