/**
 * PaymentRepository persists payment records via Database.
 */
import { database, type PaymentRecord } from "../database/database.js";

export class PaymentRepository {
  /**
   * Loads a payment by id.
   * @param id - Payment identifier
   * @returns Payment record or undefined
   */
  findById(id: string): PaymentRecord | undefined {
    return database.findPaymentById(id);
  }

  /**
   * Saves a payment entity.
   * @param payment - Payment to persist
   * @returns The saved payment
   */
  save(payment: PaymentRecord): PaymentRecord {
    database.savePayment(payment);
    return payment;
  }
}
