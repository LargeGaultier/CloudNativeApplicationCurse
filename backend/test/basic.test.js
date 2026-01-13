const test = require("node:test");
const assert = require("node:assert/strict");
const userService = require("../src/services/userService");
const userRepository = require("../src/repositories/userRepository");

test("getUserById throws when user does not exist", async () => {
  userRepository.findById = async () => null;

  await assert.rejects(() => userService.getUserById("missing-id"), {
    message: "User not found",
  });
});

test("createUser rejects duplicate email", async () => {
  userRepository.findByEmail = async () => ({ id: "u-1", email: "a@b.com" });

  await assert.rejects(
    () => userService.createUser({ email: "a@b.com" }),
    { message: "User with this email already exists" }
  );
});
