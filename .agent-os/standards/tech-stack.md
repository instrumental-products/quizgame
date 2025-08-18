# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- App Framework: Ruby on Rails 8.0+
- Language: Ruby 3.2+
- Primary Database: PostgreSQL 17+
- ORM: Active Record
- Testing framework: Rails minitest
- User authentication: Rails 8 authentication generator + Instrumental Authentication
- Background jobs queue system: SolidQueue with PostgreSQL back-end
- JavaScript Framework: Stimulus JS
- Import Strategy: Importmaps
- Package Manager: None. Not using npm nor yarn.
- CSS Framework: TailwindCSS 4.0+
- UI Components: Instrumental Components latest
- Payment Provider: Stripe (via Instrumental Components 'Commerce' system)
- Font Provider: Google Fonts
- Icons: Lucide
- Application Hosting: Digital Ocean App Platform/Droplets
- Database Hosting: Digital Ocean Managed PostgreSQL
- Asset Storage: Amazon S3
- Production Environment: main branch
- Staging Environment: staging branch
- Deployment solution: Hatchbox.io
- Transaction email sender: Resend.com
