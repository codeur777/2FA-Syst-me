package com.example._fasysteme.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class UserProfileDto {
    private Long id;
    private String email;
    private String firstName;
    private String lastName;
    private String phone;
    private String avatarUrl;
    private boolean twoFactorEnabled;
    private String theme;
    private LocalDateTime createdAt;
}
