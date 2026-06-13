package com.sms.store_management.controller;

import com.sms.store_management.config.JwtService;
import com.sms.store_management.model.User;
import com.sms.store_management.repository.UserRepository;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // 🌟 التعديل السحري هنا: يسمح لأي جهاز أو محاكي بالاتصال بدون حظر الشبكة
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    // 1. INSCRIPTION
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User user) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email already exists!"));
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "User registered successfully!"));
    }

    // 2. CONNEXION (Génère le Token JWT)
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if (userOpt.isEmpty() || !passwordEncoder.matches(request.getPassword(), userOpt.get().getPassword())) {
            return ResponseEntity.status(401).body(Map.of("message", "Invalid credentials!"));
        }
        
        var userDetails = org.springframework.security.core.userdetails.User.builder()
                .username(userOpt.get().getEmail())
                .password(userOpt.get().getPassword())
                .authorities("USER")
                .build();

        String token = jwtService.generateToken(userDetails);
        return ResponseEntity.ok(Map.of("token", token, "name", userOpt.get().getName()));
    }

    // 3. MOT DE PASSE OUBLIÉ (Envoi du code OTP à 4 chiffres)
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        Optional<User> userOpt = userRepository.findByEmail(email);
        
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("message", "Email not found"));
        }

        User user = userOpt.get();
        String otp = String.format("%04d", new Random().nextInt(10000));
        user.setOtpCode(otp);
        user.setOtpExpiryTime(LocalDateTime.now().plusMinutes(10));
        userRepository.save(user);

        System.out.println(">>> [SMS STORE] Code OTP envoyé pour " + email + " : " + otp);

        return ResponseEntity.ok(Map.of("message", "OTP sent successfully to console!"));
    }

    // 4. VERIFICATION DE L'OTP
    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");

        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) return ResponseEntity.status(404).body(Map.of("message", "User not found"));

        User user = userOpt.get();
        if (user.getOtpCode() == null || !user.getOtpCode().equals(code) || user.getOtpExpiryTime().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Invalid or expired OTP code!"));
        }

        return ResponseEntity.ok(Map.of("message", "OTP verified successfully!"));
    }

    // 5. REINITIALISATION DU MOT DE PASSE
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String newPassword = request.get("newPassword");

        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) return ResponseEntity.status(404).body(Map.of("message", "User not found"));

        User user = userOpt.get();
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setOtpCode(null);
        user.setOtpExpiryTime(null);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Password reset successfully!"));
    }
}

@Data
class LoginRequest {
    private String email;
    private String password;
}