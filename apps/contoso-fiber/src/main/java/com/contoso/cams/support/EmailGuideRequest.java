package com.contoso.cams.support;

import java.util.List;

public record EmailGuideRequest(Long caseId, Long guideId, List<SupportGuideDto> guides) {

}
