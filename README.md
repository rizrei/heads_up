# HeadsUp

HeadsUp is a small Phoenix (v1.8) web application that demonstrates a modern LiveView-first architecture with Ecto, Tailwind CSS, LiveView streams, and Swoosh-based mailer integrations. It is intended as a solid starter app and reference for building realtime UIs around incident/responder workflows.

## Key Features
- Phoenix LiveView-driven UI with server-rendered interactivity
- Ecto + PostgreSQL (binary_id / uuid primary keys)
- Live file uploads and live streams in pages (uses `phx-update="stream"`)
- Email deliverability via Swoosh (uses `Req` as the HTTP client in production)
- Tailwind CSS v4-based design with custom components

## Requirements
- Elixir ~> 1.15 (configured in [`mix.exs`](mix.exs))
- Erlang/OTP compatible with the chosen Elixir
- PostgreSQL (development/test DB settings in [`config/dev.exs`](config/dev.exs) and [`config/test.exs`](config/test.exs))
- Node tooling used by `esbuild` and `tailwind` (installed via Mix tasks / runners)
