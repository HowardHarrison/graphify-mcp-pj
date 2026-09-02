/**
 * PaymentController accepts payment requests and delegates to PaymentService.
 */
import {
  PaymentService,
  type ProcessPaymentRequest,
  type ProcessPaymentResult,
} from "./payment.service.js";
import type { PaymentRecord } from "../database/database.js";

export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  /**
   * Handles POST /payments.
   * @param body - Payment processing payload
   * @returns Result from the service layer
   */
  process(body: ProcessPaymentRequest): ProcessPaymentResult {
    return this.paymentService.processPayment(body);
  }

  /**
   * Handles GET /payments/:id.
   * @param paymentId - Payment identifier
   * @returns Payment record or undefined
   */
  getById(paymentId: string): PaymentRecord | undefined {
    return this.paymentService.getPayment(paymentId);
  }
}
