/**
 * PaymentService orchestrates gateway charges and repository persistence.
 */
import { randomUUID } from "node:crypto";
import { PaymentGateway } from "./payment.gateway.js";
import { PaymentRepository } from "./payment.repository.js";
import type { PaymentRecord } from "../database/database.js";

export interface ProcessPaymentRequest {
  userId: string;
  amount: number;
  currency: string;
}

export interface ProcessPaymentResult {
  success: boolean;
  paymentId?: string;
  status?: PaymentRecord["status"];
  message: string;
}

export class PaymentService {
  constructor(
    private readonly paymentGateway: PaymentGateway,
    private readonly paymentRepository: PaymentRepository,
  ) {}

  /**
   * Charges via PaymentGateway then stores the outcome in PaymentRepository.
   * @param request - Payer and amount details
   * @returns Processing result
   */
  processPayment(request: ProcessPaymentRequest): ProcessPaymentResult {
    const charge = this.paymentGateway.charge({
      userId: request.userId,
      amount: request.amount,
      currency: request.currency,
    });

    const payment: PaymentRecord = {
      id: randomUUID(),
      userId: request.userId,
      amount: request.amount,
      currency: request.currency,
      status: charge.accepted ? "completed" : "failed",
      providerReference: charge.providerReference || null,
    };

    this.paymentRepository.save(payment);

    return {
      success: charge.accepted,
      paymentId: payment.id,
      status: payment.status,
      message: charge.message,
    };
  }

  /**
   * Reads a previously stored payment.
   * @param paymentId - Payment identifier
   * @returns Payment record or undefined
   */
  getPayment(paymentId: string): PaymentRecord | undefined {
    return this.paymentRepository.findById(paymentId);
  }
}
