/**
 * Sample application entrypoint.
 * Wires Auth and Payment layers to demonstrate controller → service → repository → database flows.
 */
import { AuthRepository } from "./auth/auth.repository.js";
import { AuthService } from "./auth/auth.service.js";
import { AuthController } from "./auth/auth.controller.js";
import { PaymentGateway } from "./payment/payment.gateway.js";
import { PaymentRepository } from "./payment/payment.repository.js";
import { PaymentService } from "./payment/payment.service.js";
import { PaymentController } from "./payment/payment.controller.js";

const authRepository = new AuthRepository();
const authService = new AuthService(authRepository);
const authController = new AuthController(authService);

const paymentGateway = new PaymentGateway();
const paymentRepository = new PaymentRepository();
const paymentService = new PaymentService(paymentGateway, paymentRepository);
const paymentController = new PaymentController(paymentService);

/**
 * Runs a short demo of the auth and payment flows against the in-memory database.
 */
function main(): void {
  const registered = authController.register({
    email: "demo@example.com",
    password: "sample-password",
  });
  console.log("[INFO] Auth register:", registered);

  const loggedIn = authController.login({
    email: "demo@example.com",
    password: "sample-password",
  });
  console.log("[INFO] Auth login:", loggedIn);

  if (!loggedIn.userId) {
    console.error("[ERROR] Login failed; skipping payment demo");
    process.exitCode = 1;
    return;
  }

  const payment = paymentController.process({
    userId: loggedIn.userId,
    amount: 42.5,
    currency: "USD",
  });
  console.log("[INFO] Payment process:", payment);

  if (payment.paymentId) {
    console.log("[INFO] Payment lookup:", paymentController.getById(payment.paymentId));
  }
}

main();
