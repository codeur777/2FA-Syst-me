package com.example.twofa.service;

import com.example.twofa.dto.*;
import com.example.twofa.entity.OtpToken;
import com.example.twofa.entity.User;
import com.example.twofa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final OtpService otpService;
    private final UserDetailsService userDetailsService;
    private final AuthenticationManager authenticationManager;

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Cet email est déjà utilisé");
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .twoFactorEnabled(true)
                .enabled(false)
                .build();

        userRepository.save(user);
        otpService.generateAndSend(user.getEmail(), OtpToken.OtpType.TWO_FACTOR);

        return AuthResponse.builder()
                .twoFactorRequired(true)
                .email(user.getEmail())
                .message("Compte créé. Vérifiez votre email pour le code 2FA.")
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur non trouvé"));

        if (user.isTwoFactorEnabled()) {
            otpService.generateAndSend(user.getEmail(), OtpToken.OtpType.TWO_FACTOR);
            return AuthResponse.builder()
                    .twoFactorRequired(true)
                    .email(user.getEmail())
                    .message("Code 2FA envoyé par email.")
                    .build();
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        return AuthResponse.builder()
                .accessToken(jwtService.generateToken(userDetails))
                .refreshToken(jwtService.generateRefreshToken(userDetails))
                .twoFactorRequired(false)
                .email(user.getEmail())
                .build();
    }

    public AuthResponse verifyTwoFactor(VerifyOtpRequest request) {
        boolean valid = otpService.verify(request.getEmail(), request.getCode(), OtpToken.OtpType.TWO_FACTOR);
        if (!valid) throw new IllegalArgumentException("Code invalide ou expiré");

        // Activer le compte si ce n'est pas encore fait (première connexion après inscription)
        userRepository.findByEmail(request.getEmail()).ifPresent(user -> {
            if (!user.isEnabled()) {
                user.setEnabled(true);
                userRepository.save(user);
            }
        });

        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());
        return AuthResponse.builder()
                .accessToken(jwtService.generateToken(userDetails))
                .refreshToken(jwtService.generateRefreshToken(userDetails))
                .twoFactorRequired(false)
                .email(request.getEmail())
                .build();
    }

    public void resendOtp(String email) {
        userRepository.findByEmail(email).ifPresent(user ->
                otpService.generateAndSend(user.getEmail(), OtpToken.OtpType.TWO_FACTOR)
        );
    }

    public void forgotPassword(ForgotPasswordRequest request) {
        userRepository.findByEmail(request.getEmail()).ifPresent(user ->
                otpService.generateAndSend(user.getEmail(), OtpToken.OtpType.PASSWORD_RESET)
        );
    }

    public void resetPassword(ResetPasswordRequest request) {
        boolean valid = otpService.verify(request.getEmail(), request.getCode(), OtpToken.OtpType.PASSWORD_RESET);
        if (!valid) throw new IllegalArgumentException("Code invalide ou expiré");

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur non trouvé"));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }
}
