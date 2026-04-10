package com.example._fasysteme.service;

import com.example._fasysteme.dto.*;
import com.example._fasysteme.entity.User;
import com.example._fasysteme.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserProfileDto getProfile(String email) {
        User user = findByEmail(email);
        return toDto(user);
    }

    public UserProfileDto updateProfile(String email, UpdateProfileRequest request) {
        User user = findByEmail(email);
        if (request.getFirstName() != null) user.setFirstName(request.getFirstName());
        if (request.getLastName() != null) user.setLastName(request.getLastName());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        if (request.getAvatarUrl() != null) user.setAvatarUrl(request.getAvatarUrl());
        if (request.getTheme() != null) user.setTheme(request.getTheme());
        return toDto(userRepository.save(user));
    }

    public void changePassword(String email, ChangePasswordRequest request) {
        User user = findByEmail(email);
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Mot de passe actuel incorrect");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public UserProfileDto toggleTwoFactor(String email, boolean enabled) {
        User user = findByEmail(email);
        user.setTwoFactorEnabled(enabled);
        return toDto(userRepository.save(user));
    }

    private User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur non trouvé"));
    }

    private UserProfileDto toDto(User user) {
        return UserProfileDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .twoFactorEnabled(user.isTwoFactorEnabled())
                .theme(user.getTheme())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
