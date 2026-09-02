/**
 * AuthRepository persists and loads user credentials via Database.
 */
import { database, type UserRecord } from "../database/database.js";

export class AuthRepository {
  /**
   * Loads a user by email.
   * @param email - User email
   * @returns User record or undefined when not found
   */
  findByEmail(email: string): UserRecord | undefined {
    return database.findUserByEmail(email);
  }

  /**
   * Creates or updates a user in the database.
   * @param user - User entity to persist
   * @returns The saved user
   */
  save(user: UserRecord): UserRecord {
    database.saveUser(user);
    return user;
  }
}
