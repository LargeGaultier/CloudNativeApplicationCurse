module.exports = {
  root: true,
  env: { browser: true, es2021: true, node: true },
  parser: "vue-eslint-parser",
  parserOptions: {
    parser: "espree",
    ecmaVersion: "latest",
    sourceType: "module",
  },
  extends: ["eslint:recommended", "plugin:vue/recommended"],
};
