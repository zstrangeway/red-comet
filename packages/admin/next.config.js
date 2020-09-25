/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable no-undef */
require("dotenv").config();

module.exports = {
  distDir: "../../dist/admin",
  env: {
    API_URL: process.env.API_URL,
  },
};
