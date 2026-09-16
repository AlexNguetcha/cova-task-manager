package com.covataskmanager;

import com.covataskmanager.dto.RegisterRequest;
import com.covataskmanager.entity.User;
import com.covataskmanager.exception.DuplicateResourceException;
import com.covataskmanager.repository.UserRepository;
import com.covataskmanager.security.JwtTokenProvider;
import com.covataskmanager.service.AuthService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    private PasswordEncoder passwordEncoder;
    private AuthService authService;

    @BeforeEach
    void setUp() {
        passwordEncoder = new BCryptPasswordEncoder();
        authService = new AuthService(userRepository, passwordEncoder, jwtTokenProvider);
    }

    @Test
    void shouldRegisterUser() {
        var request = RegisterRequest.builder()
                .name("Alex")
                .email("alex@test.com")
                .password("password123")
                .build();

        when(userRepository.existsByEmail("alex@test.com")).thenReturn(false);
        when(jwtTokenProvider.generateAccessToken("alex@test.com")).thenReturn("access-token");
        when(jwtTokenProvider.generateRefreshToken("alex@test.com")).thenReturn("refresh-token");
        when(userRepository.save(any(User.class))).thenAnswer(inv -> {
            var u = inv.<User>getArgument(0);
            u.setId(1L);
            return u;
        });

        var response = authService.register(request);

        assertThat(response.getAccessToken()).isEqualTo("access-token");
        assertThat(response.getUser().getEmail()).isEqualTo("alex@test.com");
        assertThat(response.getUser().getName()).isEqualTo("Alex");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void shouldThrowWhenEmailAlreadyExists() {
        when(userRepository.existsByEmail("alex@test.com")).thenReturn(true);

        var request = RegisterRequest.builder()
                .email("alex@test.com")
                .password("pass123")
                .name("Alex")
                .build();

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessageContaining("Email already registered");
    }

    @Test
    void shouldThrowOnInvalidLogin() {
        when(userRepository.findByEmail("wrong@test.com")).thenReturn(java.util.Optional.empty());

        var request = com.covataskmanager.dto.LoginRequest.builder()
                .email("wrong@test.com")
                .password("pass")
                .build();

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(BadCredentialsException.class);
    }
}