package com.thamienotes.notetaking.dtos.Auth;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApiResponseMessageDto<T> {
    private int status;
    private String message;
    private T data;
    private LocalDateTime timestamp;

    public ApiResponseMessageDto(int status, String message, T data) {
        this.status = status;
        this.message = message;
        this.data = data;
        this.timestamp = LocalDateTime.now();
    }

}
