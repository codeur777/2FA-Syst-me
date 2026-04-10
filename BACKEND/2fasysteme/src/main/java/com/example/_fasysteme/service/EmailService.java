package com.example._fasysteme.service;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendOtpEmail(String to, String code, String type) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);

        if ("TWO_FACTOR".equals(type)) {
            message.setSubject("🔐 Votre code de vérification 2FA");
            message.setText(
                "Bonjour,\n\n" +
                "Votre code de vérification est : " + code + "\n\n" +
                "Ce code expire dans 10 minutes.\n" +
                "Si vous n'avez pas demandé ce code, ignorez cet email.\n\n" +
                "— L'équipe 2FA Systeme"
            );
        } else {
            message.setSubject("🔑 Réinitialisation de votre mot de passe");
            message.setText(
                "Bonjour,\n\n" +
                "Votre code de réinitialisation est : " + code + "\n\n" +
                "Ce code expire dans 10 minutes.\n" +
                "Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.\n\n" +
                "— L'équipe 2FA Systeme"
            );
        }

        mailSender.send(message);
    }
}
