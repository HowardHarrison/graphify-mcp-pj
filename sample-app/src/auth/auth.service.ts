/**
 * AuthService implements login and registration business rules.
 */
import { randomUUID, createHash } from "node:crypto";
import { AuthRepository } from "./auth.repository.js";
import type { UserRecord } from "../database/database.js";

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
}

export interface AuthResult {
  success: boolean;
  userId?: string;
  token?: string;
  message: string;
}

export class AuthService {
  constructor(private readonly authRepository: AuthRepository) {}

  /**
   * Registers a new user after checking for duplicates.
   * @param request - Email and password
   * @returns Auth result with token on success
   */
  register(request: RegisterRequest): AuthResult {
    const existing = this.authRepository.findByEmail(request.email);
    if (existing) {
      return { success: false, message: "Email already registered" };
    }

    const user: UserRecord = {
      id: randomUUID(),
      email: request.email,
      passwordHash: this.hashPassword(request.password),
    };
    this.authRepository.save(user);

    return {
      success: true,
      userId: user.id,
      token: this.createToken(user.id),
      message: "Registered",
    };
  }

  /**
   * Authenticates a user with email and password.
   * @param request - Login credentials
   * @returns Auth result with token on success
   */
  login(request: LoginRequest): AuthResult {
    const user = this.authRepository.findByEmail(request.email);
    if (!user || user.passwordHash !== this.hashPassword(request.password)) {
      return { success: false, message: "Invalid credentials" };
    }

    return {
      success: true,
      userId: user.id,
      token: this.createToken(user.id),
      message: "Authenticated",
    };
  }

  /**
   * Hashes a password for storage comparison (sample only — not production-grade).
   * @param password - Plaintext password
   * @returns Hex digest
   */
  private hashPassword(password: string): string {
    return createHash("sha256").update(password).digest("hex");
  }

  /**
   * Creates a opaque sample token.
   * @param userId - Authenticated user id
   * @returns Token string
   */
  private createToken(userId: string): string {
    return createHash("sha256").update(`${userId}:${Date.now()}`).digest("hex");
  }
}
