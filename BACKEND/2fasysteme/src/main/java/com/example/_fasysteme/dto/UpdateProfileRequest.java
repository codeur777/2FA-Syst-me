package com.example._fasysteme.dto;

import lombok.Data;

@Data
public class UpdateProfileRequest {
    private String firstName;
    private String lastName;
    private String phone;
    private String avatarUrl;
    private String theme;
}
