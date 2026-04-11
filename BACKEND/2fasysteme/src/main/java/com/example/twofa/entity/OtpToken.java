package com.example.twofa.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "otp_tokens")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class OtpToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String code;

    @Column(nullable = false)
    private LocalDateTime expiresAt;

    @Column(nullable = false)
    @Builder.Default
    private boolean used = false;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OtpType type;

    public enum OtpType {
        TWO_FACTOR, PASSWORD_RESET
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
}
