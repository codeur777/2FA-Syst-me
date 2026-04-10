package com.example._fasysteme.service;

import com.example._fasysteme.entity.OtpToken;
import com.example._fasysteme.repository.OtpTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OtpService {

    private final OtpTokenRepository otpTokenRepository;
    private final EmailService emailService;

    @Value("${app.otp.expiration-minutes}")
    private int expirationMinutes;

    @Value("${app.otp.length}")
    private int otpLength;

    public void generateAndSend(String email, OtpToken.OtpType type) {
        // Invalider les anciens codes
        otpTokenRepository.invalidateAllByEmailAndType(email, type);

        String code = generateCode();

        OtpToken token = OtpToken.builder()
                .email(email)
                .code(code)
                .type(type)
                .expiresAt(LocalDateTime.now().plusMinutes(expirationMinutes))
                .build();

        otpTokenRepository.save(token);
        emailService.sendOtpEmail(email, code, type.name());
    }

    public boolean verify(String email, String code, OtpToken.OtpType type) {
        return otpTokenRepository
                .findTopByEmailAndTypeAndUsedFalseOrderByExpiresAtDesc(email, type)
                .map(token -> {
                    if (token.isExpired()) return false;
                    if (!token.getCode().equals(code)) return false;
                    token.setUsed(true);
                    otpTokenRepository.save(token);
                    return true;
                })
                .orElse(false);
    }

    private String generateCode() {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < otpLength; i++) {
            sb.append(random.nextInt(10));
        }
        return sb.toString();
    }
}
