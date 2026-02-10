# GenX CMS

> ⚠️ **Archived Project** — This repository is preserved for historical reference. It is no longer maintained and is not recommended for production use.

## Overview

GenX is a ColdFusion-based Model-View-Controller CMS developed internally at [Corporate 3 Design](http://www.corporate3design.com), an Omaha-based web design and development studio. It was built to solve a specific real-world problem: enabling a small studio team to rapidly deploy and manage client websites from a single, consistent codebase.

At its peak, GenX powered approximately 100 client websites.

## Background

Most off-the-shelf CMS platforms of the era required significant customization for each client deployment. GenX was built from the ground up around the needs of a working design studio — prioritizing speed of deployment, consistency across sites, and ease of content management for non-technical clients.

The MVC architecture was a deliberate design choice, separating concerns cleanly at a time when most ColdFusion applications were still mixing logic and presentation in a single file. The framework predates the widespread adoption of popular ColdFusion MVC frameworks like FW/1 and ColdBox.

## Features

- MVC architecture built on ColdFusion
- Step-by-step web-based installer
- Automatic ColdFusion datasource creation via the CFIDE Admin API
- Support for both Adobe ColdFusion and Railo
- Apache (.htaccess) and IIS (web.config) compatibility
- Installer self-deletes after setup for security
- Management center for site administration

## Requirements

- ColdFusion (Adobe ColdFusion or Railo)
- MySQL 5.x
- Apache or IIS web server

## Installation

1. Upload the codebase to your web server
2. Navigate to `/default/installer/` in your browser
3. Follow the 5-step installation wizard:
   - **Step 1** — Configure datasource and set web root paths
   - **Step 2** — Copy default template files to web root
   - **Step 3** — Initialize support objects
   - **Step 4** — Delete the installer directory
   - **Step 5** — Launch the management center
4. Log in to the management center and configure your site settings

## History

- Developed at Corporate 3 Design, Omaha, Nebraska
- Active development approximately 2010–2016
- Deployed on approximately 100 client sites at peak usage
- Corporate 3 Design closed; assets acquired by original developer

## License

MIT License — free to use, modify, and distribute. No support or maintenance is provided.

---

*GenX was built by a small studio team to ship real websites for real clients. It worked.*
