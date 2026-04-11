package com.example.twofa.repository;

import com.example.twofa.entity.OtpToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

public interface OtpTokenRepository extends JpaRepository<OtpToken, Long> {

    Optional<OtpToken> findTopByEmailAndTypeAndUsedFalseOrderByExpiresAtDesc(
        String email, OtpToken.OtpType type);

    @Modifying
    @Transactional
    @Query("UPDATE OtpToken o SET o.used = true WHERE o.email = :email AND o.type = :type")
    void invalidateAllByEmailAndType(String email, OtpToken.OtpType type);
}
