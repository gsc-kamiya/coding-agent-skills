// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  site: 'https://{{OWNER}}.github.io',
  base: '/{{SITE_NAME}}/',
  output: 'static',
});
