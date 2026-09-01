# Vi Shop

A customized [Spree Commerce 5](https://spreecommerce.org) storefront and admin, built on top of the official Spree Starter. It runs in production at **[menu-spree.online](https://menu-spree.online)** and is deployed with [Kamal](https://kamal-deploy.org).

The base stack (Spree 5, Rails 8, Ruby 3.3.1, PostgreSQL, Redis, Sidekiq, Devise, Stripe, Google Analytics, Klaviyo) is unchanged from the Spree Starter. Everything below is what makes **this** app different — all customizations live in `app/` and `config/` following the Spree decorator/override pattern (no forked gems).

## Base stack

* **[Spree Commerce 5](https://spreecommerce.org/announcing-spree-5-the-biggest-open-source-release-ever/)** — Admin Dashboard, API, and Storefront
* Stripe payments ([spree_stripe](https://github.com/spree/spree_stripe))
* Google Analytics 4 ([spree_google_analytics](https://github.com/spree/spree_google_analytics))
* Klaviyo ([spree_klaviyo](https://github.com/spree/spree_klaviyo))
* [Devise](https://github.com/heartcombo/devise) authentication, [Sidekiq](https://github.com/mperham/sidekiq) background jobs
* PostgreSQL + Redis
* AWS S3 for Active Storage (production)
* (Optional) [Sentry](https://sentry.io) monitoring, [SendGrid](https://sendgrid.com) transactional email

## Customizations vs. Spree Starter

### 1. Custom "Vi" storefront theme
* `Spree::Themes::Vi` (`app/models/spree/themes/vi.rb`), registered in `config/initializers/spree.rb`, subclasses the default theme.
* Custom section views live under `app/views/themes/vi/...` (header, footer, product details, filters, price, media gallery) with a matching set under `app/views/themes/default/...`.

### 2. Custom page sections & blocks (no-code storefront builder)
Registered in `config/initializers/spree.rb` and editable from the admin page builder:

**Page sections** — `ImageGrid`, `ImageSlider`, `FullscreenBanner`, `RiskReducers`, `CollectionSlider`, `YoutubeShortsSlider` (plus decorators for `ImageBanner`, `ImageWithText`, `Newsletter`).

**Page blocks** — `ImageGridBlock`, `ImageCollectionSlider`, `YoutubeShort`.

Each has a model (`app/models/spree/page_sections|page_blocks/`), an admin form partial (`app/views/spree/admin/...`), and a storefront partial. Section images can be set by upload **or** by external `image_url`/`video_url`.

### 3. Product enhancements (`app/models/vi/spree/product_decorator.rb`)
On product create:
* **Auto SKU generation** — a unique `PREFIX-XXXXX` SKU derived from the product name.
* **Default price** — falls back to `1` when left blank (so listings can be created without a price).
* **Default stock** — seeds 1 unit at the default stock location.
* **Telegram notification** — enqueues a job announcing the new listing (see below).

Extra product fields stored in `public_metadata` and exposed on the model:
* `video_url` — a product video (rendered via `_video` / `_video_play_icon` partials).
* `image_urls` — external image URLs (newline/comma separated).
* `card_size` — storefront card size: `normal`, `wide`, or `large` (see `product_card_helper.rb`).

These are whitelisted in `config/initializers/spree_permitted_attributes.rb` and added to the admin product form via `app/overrides/add_video_to_admin_product.rb`.

### 4. Telegram integration
* `TelegramNotifier` service (`app/services/`) posts to the Telegram Bot API via Faraday.
* `TelegramNotificationJob` runs it async through Sidekiq.
* Triggered when a new product/listing is created.
* Configured with `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` env vars.

### 5. Moderator role
A limited admin role between customer and full admin:
* `Spree::AbilityDecorator` (`app/models/spree/ability_decorator.rb`) grants a `moderator` role `manage :all` **except** orders, promotions, reports, payment/shipping/tax/zone config, stock, returns, and custom domains.
* `app/overrides/hide_admin_sections_for_moderator.rb` (Deface) hides the shipping/inventory sections on the admin product form for moderators.
* `app/helpers/spree/admin/moderator_helper.rb` supports the UI.

### 6. Product importer from Google Sheets (admin)
Bulk-import and update products into `/admin/products` from a **public** Google Sheet. Runs in the background via Sidekiq and reports the result to Telegram.

**How to use**
1. In `/admin/products`, click **"Импорт из Google Sheets"** (top-right, next to *New product*).
2. Paste the link to a Google Sheet shared as *"anyone with the link — Viewer"* and submit.
3. The import is queued; when it finishes you get a Telegram message like
   `✅ Products import finished — created: 0, updated: 1, skipped: 0, errors: 0`.

**Sheet columns** (header row, case-insensitive, spaces → underscores). Only `name` is required:

| Column | Meaning |
| --- | --- |
| `name` | Product name **(required)** |
| `price` | Master price (falls back to `1` when blank) |
| `sku` | Match key for upsert; auto-generated when blank |
| `description` | Product description |
| `image_url` | Image URL(s), several separated by comma/newline (alias `image_urls`) |
| `video_url` | Product video URL (stored in `public_metadata`) |
| `card_size` | Storefront card size: `normal` / `wide` / `large` |
| `taxons` | Taxon path(s), e.g. `Categories > Food > Pizza`; multiple paths separated by `;` (aliases `taxonomies`, `category`) |
| `properties` | Inline product properties: `Key: Value; Key2: Value2` |
| `property: X` | Any column whose header starts with `property:` sets property *X* to the cell value |

**Behaviour**
* **Upsert & update** — rows are matched by `sku`, then by `name`. Existing products are updated, so re-importing an edited sheet updates the matching products. A product counts as *updated* only if something actually changed (attributes, store, a property, a taxon, or a newly attached image); unchanged products are not counted.
* **Taxons** — the first path segment is the taxonomy name (auto-created with its root taxon); remaining segments are nested taxons, created if missing. A single-segment value goes under the `Categories` taxonomy. The `taxons` cell is **authoritative**: on re-import, taxons no longer listed are removed and a blank cell clears all taxons (if the column is absent from the sheet, taxons are left untouched).
* **Images & video** — `image_url` values are stored in `public_metadata` (detail-page gallery) and the first image is also attached as a real `Spree::Image` for listing cards; `video_url` is stored in `public_metadata`. Both columns are **authoritative**: clearing the `image_url` cell removes the stored URL(s) and the imported product image, and clearing `video_url` removes the video (columns absent from the sheet are left untouched).
* **New products** — on create the product decorator auto-generates a SKU, sets a default price/stock, and sends the usual new-product Telegram notification.

### 7. Deployment (Kamal → menu-spree.online)
* `config/deploy.yml` — separate `web` and `job` (Sidekiq) roles, SSL via Let's Encrypt, image `vi4me/menu-spree`, Redis over the private Kamal network.
* `bin/deploy` wrapper; `.env.deploy` is gitignored.
* AWS S3 credentials stored in Rails encrypted credentials.

## Local Installation

Follow the [Spree Quickstart guide](https://spreecommerce.org/docs/developer/getting-started/quickstart). In short:

```bash
docker-compose up -d      # Postgres (5432) + Redis (6379)
bin/setup                 # bundle, db:prepare, db:seed, .env
bin/dev                   # web + sidekiq + dartsass:watch + tailwindcss:watch
```

> Use `bin/dev`, **not** `rails server` — the two CSS watchers (Dart Sass for admin, Tailwind for storefront) are required or you'll serve stale stylesheets.

Admin is at `/admin`, Sidekiq UI at `/sidekiq`, health check at `/up`.

## Running tests

`spec/` covers the local customizations (decorators, custom controllers, services):

```bash
bundle exec rspec
bundle exec rubocop      # lint
bundle exec brakeman     # security scan
```

## Environment / secrets

Configured via `.env` and Rails encrypted credentials. Notable keys beyond the Spree defaults: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, AWS S3 credentials, `KAMAL_REGISTRY_PASSWORD`.

> ⚠️ Treat any secret checked into `.env` as compromised and rotate it before deploying.

## Troubleshooting

### libvips error

If you see `LoadError: Could not open library 'vips.so.42'`, check `vips -v` and install libvips per the [instructions here](https://www.libvips.org/install.html).

---

Built on [Spree Commerce](https://spreecommerce.org) open-source. [Join the Spree Slack](https://slack.spreecommerce.org) for community support.
