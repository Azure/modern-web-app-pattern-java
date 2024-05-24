package com.contoso.cams.support;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.contoso.cams.model.Account;
import com.contoso.cams.model.AccountRepository;
import com.contoso.cams.model.ActivityType;
import com.contoso.cams.model.Customer;
import com.contoso.cams.model.SupportCase;
import com.contoso.cams.model.SupportCaseActivity;
import com.contoso.cams.model.SupportCaseActivityRepository;
import com.contoso.cams.model.SupportCaseQueue;
import com.contoso.cams.model.SupportCaseRepository;
import com.contoso.cams.model.SupportGuide;
import com.contoso.cams.model.SupportGuideRepository;
import com.contoso.cams.security.UserInfo;
import com.contoso.cams.services.SupportGuideSender;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@AllArgsConstructor
@Slf4j
public class SupportCaseService {

    private final AccountRepository accountRepository;
    private final SupportCaseRepository supportCaseRepository;
    private final SupportCaseActivityRepository supportCaseActivityRepository;
    private final SupportGuideRepository supportGuideRepository;
    private final SupportGuideSender supportGuideSender;

    public NewSupportCaseRequest generateNewSupportCaseRequest(Long accountId) {

        Optional<Account> account = accountRepository.findById(accountId);

        if (account.isEmpty()) {
            throw new IllegalArgumentException("Account with id " + accountId + " does not exist.");
        }

        NewSupportCaseRequest newSupportCaseRequest = new NewSupportCaseRequest();
        newSupportCaseRequest.setAccountId(accountId);
        newSupportCaseRequest.setCustomerFirstName(account.get().getCustomer().getFirstName());
        newSupportCaseRequest.setCustomerLastName(account.get().getCustomer().getLastName());
        newSupportCaseRequest.setCustomerEmailAddress(account.get().getCustomer().getEmailAddress());
        newSupportCaseRequest.setCustomerPhoneNumber(account.get().getCustomer().getPhoneNumber());

        return newSupportCaseRequest;
    }

    @Transactional
    @CacheEvict(value = "account-details", key = "#newSupportCaseRequest.getAccountId()")
    public void createSupportCase(NewSupportCaseRequest newSupportCaseRequest) {
        Optional<Account> account = accountRepository.findById(newSupportCaseRequest.getAccountId());
        if (account.isEmpty()) {
            throw new IllegalArgumentException("Account with id " + newSupportCaseRequest.getAccountId() + " does not exist.");
        }
        SupportCase supportCase = new SupportCase();
        supportCase.setDescription(newSupportCaseRequest.getDescription());
        supportCase.setQueue(SupportCaseQueue.L1);
        supportCase.setAccount(account.get());

        SupportCaseActivity supportCaseActivity = new SupportCaseActivity();
        supportCaseActivity.setNotes("New support case created");
        supportCaseActivity.setActivityType(ActivityType.NOTE);

        supportCaseActivity.setSupportCase(supportCase);

        supportCaseRepository.save(supportCase);
        supportCaseActivityRepository.save(supportCaseActivity);
    }

    public SupportCaseDetails getSupportCaseDetails(Long id) {
        Optional<SupportCase> supportCase = supportCaseRepository.findById(id);
        if (supportCase.isEmpty()) {
            throw new IllegalArgumentException("Support case with id " + id + " does not exist.");
        }

        SupportCaseDetails supportCaseDetails = createFrom(supportCase.get());

        List<SupportCaseActivityDto> activityDtos = supportCase.get().getActivities().stream()
            .map(a -> {
                var dto = new SupportCaseActivityDto();
                dto.setId(a.getId());
                dto.setActivityType(a.getActivityType());
                dto.setNotes(a.getNotes());
                dto.setTimestamp(a.getTimestamp());
                return dto;
            })
            .collect(Collectors.toList());

        supportCaseDetails.setActivities(activityDtos);

        List<SupportGuide> supportGuides = supportGuideRepository.findAll();
        List<SupportGuideDto> supportGuideDtos = supportGuides.stream()
            .map(g -> new SupportGuideDto(g.getId(), g.getName()))
            .collect(Collectors.toList());

        EmailGuideRequest emailGuideRequest = new EmailGuideRequest(id, null, supportGuideDtos);

        supportCaseDetails.setEmailGuideRequest(emailGuideRequest);

        return supportCaseDetails;
    }

    public List<SupportGuide> getAllSupportGuides() {
        return supportGuideRepository.findAll();
    }

    public void createSupportCaseActivity(NewSupportCaseActivityRequest newSupportCaseActivityRequest) {
        Optional<SupportCase> supportCase = supportCaseRepository.findById(newSupportCaseActivityRequest.caseId());
        if (supportCase.isEmpty()) {
            throw new IllegalArgumentException("Support case with id " + newSupportCaseActivityRequest.caseId() + " does not exist.");
        }

        SupportCaseActivity supportCaseActivity = new SupportCaseActivity();
        supportCaseActivity.setNotes(newSupportCaseActivityRequest.notes());
        supportCaseActivity.setActivityType(newSupportCaseActivityRequest.activityType());
        supportCaseActivity.setSupportCase(supportCase.get());

        addNewSupportCaseActivity(supportCaseActivity);
    }

    private void addNewSupportCaseActivity(SupportCaseActivity supportCaseActivity) {
        supportCaseActivityRepository.save(supportCaseActivity);
    }

    public void assignSupportCaseToQueue(Long id, SupportCaseQueue supportCaseQueue) {
        Optional<SupportCase> supportCase = supportCaseRepository.findById(id);
        if (supportCase.isEmpty()) {
            throw new IllegalArgumentException("Support case with id " + id + " does not exist.");
        }

        supportCase.get().setQueue(supportCaseQueue);
        supportCaseRepository.save(supportCase.get());
    }

    public void assignSupportCaseToUser(Long id, UserInfo user) {
        Optional<SupportCase> supportCase = supportCaseRepository.findById(id);
        if (supportCase.isEmpty()) {
            throw new IllegalArgumentException("Support case with id " + id + " does not exist.");
        }
        supportCase.get().setAssignedTo(user.employeeId());
        supportCaseRepository.save(supportCase.get());
    }

    public List<SupportCaseDetails> getSupportCasesAssignedToUser(UserInfo user) {
        List<SupportCase> supportCases = supportCaseRepository.findAllByAssignedTo(user.employeeId());
        List<SupportCaseDetails> supportCaseDetails = supportCases.stream()
            .map(s -> createFrom(s))
            .collect(Collectors.toList());

        return supportCaseDetails;
    }

    public List<SupportCaseDetails> getAllSupportCases() {
        List<SupportCase> supportCases = supportCaseRepository.findAll();
        List<SupportCaseDetails> supportCaseDetails = supportCases.stream()
            .map(s -> createFrom(s))
            .collect(Collectors.toList());

        return supportCaseDetails;
    }

    public List<SupportCaseDetails> getSupportCasesByQueue(SupportCaseQueue queue) {
        List<SupportCase> supportCases = supportCaseRepository.findAllByQueue(queue);
        List<SupportCaseDetails> supportCaseDetails = supportCases.stream()
            .map(s -> createFrom(s))
            .collect(Collectors.toList());

        return supportCaseDetails;
    }

    private static SupportCaseDetails createFrom(SupportCase supportCase) {
        SupportCaseDetails supportCaseDetails = new SupportCaseDetails();
        supportCaseDetails.setCaseId(supportCase.getId());
        supportCaseDetails.setDescription(supportCase.getDescription());
        supportCaseDetails.setStatus(supportCase.getQueue());
        supportCaseDetails.setAssignee(supportCase.getAssignedTo());
        supportCaseDetails.setCreationDate(supportCase.getTimestamp());

        Account account = supportCase.getAccount();
        supportCaseDetails.setAccountId(account.getId());
        supportCaseDetails.setAddress(account.getAddress());
        supportCaseDetails.setCity(account.getCity());

        Customer customer = account.getCustomer();
        supportCaseDetails.setCustomerFirstName(customer.getFirstName());
        supportCaseDetails.setCustomerLastName(customer.getLastName());
        supportCaseDetails.setCustomerEmailAddress(customer.getEmailAddress());
        supportCaseDetails.setCustomerPhoneNumber(customer.getPhoneNumber());

        return supportCaseDetails;
    }

    public void emailGuide(Long id, Long guideId) {
        Optional<SupportCase> supportCase = supportCaseRepository.findById(id);
        if (supportCase.isEmpty()) {
            throw new IllegalArgumentException("Support case with id " + id + " does not exist.");
        }

        Optional<SupportGuide> supportGuide = supportGuideRepository.findById(guideId);
        if (supportGuide.isEmpty()) {
            throw new IllegalArgumentException("Support guide with id " + guideId + " does not exist.");
        }

        createEmailSupportCaseActivity(supportCase.get(), supportGuide.get());
        sendEmailMessage(supportCase.get(), supportGuide.get(), supportCase.get().getId());
    }

    private void createEmailSupportCaseActivity(SupportCase supportCase, SupportGuide supportGuide) {
        final String notes = "Emailing support guide " + supportGuide.getName();
        final ActivityType activityType = ActivityType.OUTBOUND_EMAIL;

        SupportCaseActivity supportCaseActivity = new SupportCaseActivity();
        supportCaseActivity.setNotes(notes);
        supportCaseActivity.setActivityType(activityType);
        supportCaseActivity.setSupportCase(supportCase);

        addNewSupportCaseActivity(supportCaseActivity);
    }

    private void sendEmailMessage(SupportCase supportCase, SupportGuide supportGuide, Long activityId) {
        Customer customer = supportCase.getAccount().getCustomer();
        supportGuideSender.send(customer.getEmailAddress(), supportGuide.getUrl(), activityId);
        log.info("Sending email to customer {} {} for support case {} with guide {}", customer.getFirstName(), customer.getLastName(), supportCase.getId(), supportGuide.getId());
    }
}
