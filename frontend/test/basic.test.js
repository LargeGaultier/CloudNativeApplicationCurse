import test from "node:test";
import assert from "node:assert/strict";
import { createPinia, setActivePinia } from "pinia";
import { useAuthStore } from "../src/store/auth.js";

const makeLocalStorage = () => {
  const store = new Map();
  return {
    getItem(key) {
      return store.has(key) ? store.get(key) : null;
    },
    setItem(key, value) {
      store.set(key, value);
    },
    removeItem(key) {
      store.delete(key);
    },
  };
};

test("initAuth restores currentUser and updates role flags", () => {
  globalThis.localStorage = makeLocalStorage();

  const user = { id: "u-1", email: "admin@gym.local", role: "ADMIN" };
  localStorage.setItem("currentUser", JSON.stringify(user));

  setActivePinia(createPinia());
  const store = useAuthStore();
  store.initAuth();

  assert.equal(store.isAuthenticated, true);
  assert.equal(store.isAdmin, true);
  assert.equal(store.currentUser.email, "admin@gym.local");
});
