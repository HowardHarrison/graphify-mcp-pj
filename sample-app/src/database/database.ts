/**
 * In-memory database stub used by Auth and Payment repositories.
 * Represents the persistence boundary for Graphify relationship tracing.
 */
export interface UserRecord {
  id: string;
  email: string;
  passwordHash: string;
}

export interface PaymentRecord {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  status: "pending" | "completed" | "failed";
  providerReference: string | null;
}

/**
 * Simple in-memory store. Not an application database product —
 * exists so the code graph can show Repository → Database edges.
 */
export class Database {
  private readonly users = new Map<string, UserRecord>();
  private readonly payments = new Map<string, PaymentRecord>();

  /**
   * Finds a user by email address.
   * @param email - Normalized email to look up
   * @returns Matching user or undefined
   */
  findUserByEmail(email: string): UserRecord | undefined {
    for (const user of this.users.values()) {
      if (user.email === email) {
        return user;
      }
    }
    return undefined;
  }

  /**
   * Persists a user record.
   * @param user - User entity to store
   */
  saveUser(user: UserRecord): void {
    this.users.set(user.id, user);
  }

  /**
   * Finds a payment by identifier.
   * @param id - Payment id
   * @returns Matching payment or undefined
   */
  findPaymentById(id: string): PaymentRecord | undefined {
    return this.payments.get(id);
  }

  /**
   * Persists a payment record.
   * @param payment - Payment entity to store
   */
  savePayment(payment: PaymentRecord): void {
    this.payments.set(payment.id, payment);
  }
}

/** Shared database instance for the sample application. */
export const database = new Database();
