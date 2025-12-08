import vue from "eslint-plugin-vue";

export default [
  {
    files: ["**/*.vue"],
    ignores: ["dist/**"],

    languageOptions: {
      parser: vue.parser,
      ecmaVersion: "latest",
      sourceType: "module",
    },

    plugins: {
      vue,
    },

    rules: {
      // Règles minimales nécessaires pour Vue 3
      "vue/no-unused-vars": "warn",
      "vue/no-mutating-props": "error",
      "vue/no-dupe-keys": "error",
      "vue/no-unused-components": "warn",
      "vue/multi-word-component-names": "off"
    }
  },

  {
    files: ["**/*.js"],
    ignores: ["dist/**"],

    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
    },

    rules: {
      "no-unused-vars": "warn",
      "no-undef": "error"
    }
  }
];