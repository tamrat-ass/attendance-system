/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
  // Note: `eslint` option and `experimental.turbo` are removed
  // because Next.js no longer supports configuring eslint in
  // `next.config.mjs` and `experimental.turbo` is unrecognized.
}

export default nextConfig
