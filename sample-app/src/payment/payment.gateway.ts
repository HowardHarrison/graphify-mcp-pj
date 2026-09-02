/**
 * PaymentGateway talks to an external payment provider (stubbed).
 */
export interface ChargeRequest {
  amount: number;
  currency: string;
  userId: string;
}

export interface ChargeResponse {
  accepted: boolean;
  providerReference: string;
  message: string;
}

export class PaymentGateway {
  /**
   * Charges a card through the external provider stub.
   * @param request - Amount, currency, and payer
   * @returns Provider response with a reference id
   */
  charge(request: ChargeRequest): ChargeResponse {
    if (request.amount <= 0) {
      return {
        accepted: false,
        providerReference: "",
        message: "Amount must be positive",
      };
    }

    return {
      accepted: true,
      providerReference: `gw_${request.userId}_${Date.now()}`,
      message: "Charge accepted",
    };
  }
}
