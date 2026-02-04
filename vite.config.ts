/// <reference types="vitest" />
/// <reference types="vite/client" />

import path from "path";
import react from "@vitejs/plugin-react";
import { defineConfig, loadEnv } from "vite";

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "VITE_");

  return {
    plugins: [react()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
    preview: {
      port: 8080,
      strictPort: true,
    },
    server: {
      port: parseInt(env.VITE_SERVER_PORT) || 8080,
      strictPort: true,
      host: "0.0.0.0",
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    },
    test: {
      globals: true,
      environment: "jsdom",
      setupFiles: "./src/test/setup.ts",
      css: true,
    },
  };
});
