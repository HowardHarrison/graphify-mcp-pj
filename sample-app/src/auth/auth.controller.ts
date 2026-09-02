/**
 * AuthController accepts HTTP-style auth requests and delegates to AuthService.
 */
import { AuthService, type AuthResult, type LoginRequest, type RegisterRequest } from "./auth.service.js";

export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Handles POST /auth/register.
   * @param body - Registration payload
   * @returns Auth result from the service layer
   */
  register(body: RegisterRequest): AuthResult {
    return this.authService.register(body);
  }

  /**
   * Handles POST /auth/login.
   * @param body - Login payload
   * @returns Auth result from the service layer
   */
  login(body: LoginRequest): AuthResult {
    return this.authService.login(body);
  }
}
