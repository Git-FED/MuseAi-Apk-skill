# Website deployment

## Recommended: GitHub repository → Cloudflare Pages

Keep GitHub as the source repository and use Cloudflare Pages as the production host. The site is static; it does not need a framework, package install, environment variables, or an application server. Connect the GitHub repository to a Pages project. Cloudflare Pages can build and deploy from a connected Git repository and create preview deployments for branches and pull requests [1].

Use these Pages build settings:

- **Production branch:** the repository’s chosen production branch, typically `main`.
- **Root directory:** `/` (the repository root).
- **Build command:** `mkdir -p dist && cp index.html dist/ && cp -R assets dist/`.
- **Build output directory:** `dist`.
- **Environment variables:** none required for the static page.

The copy step deliberately publishes only `index.html` and `assets/`; it does not publish the test scripts, setup files, or internal project documentation as website routes. Keep the asset links relative (`assets/...`) so the favicon and images work on both root domains and GitHub Pages project paths.

After connecting the repository, push to the selected production branch and verify the production URL, favicon, promotional images, mobile layout, and age-gate behavior. A pull request should use the Cloudflare preview URL for review before it is merged. Configure a custom domain and any DNS changes in the Cloudflare dashboard; no domain or deployment status is assumed in this repository.

## If GitHub Pages itself is the origin

If you mean GitHub Pages should host the site and Cloudflare should sit in front of it, enable GitHub Pages separately and configure Cloudflare routing/DNS for that domain. That is a different setup from Cloudflare Pages Git integration. Avoid deploying the same domain from both GitHub Pages and Cloudflare Pages at once; choose one production origin. Relative asset paths are intentional so a GitHub Pages project URL such as `/<repository>/` can resolve its favicon and images.

## When to use a Worker

For this static landing page, Cloudflare Pages is the simpler fit and does not need Worker code. Add a Cloudflare Worker only if the project later needs request-time logic such as API endpoints, custom routing, or response transformations. Workers can serve a configured static-assets directory and run Worker code alongside those assets [2]. If adding that path, build the same `dist/` directory and configure the Worker’s static assets to use it; do not point public hosting at the repository root.

## References

[1]: https://developers.cloudflare.com/pages/configuration/git-integration/ "Cloudflare Pages Git integration"
[2]: https://developers.cloudflare.com/workers/static-assets/ "Cloudflare Workers static assets"
