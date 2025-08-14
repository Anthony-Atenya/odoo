# Odoo 18 base image
FROM odoo:18.0

USER root

# Install wkhtmltopdf (patched Qt) + fonts and deps for PDFs
# Use Bookworm builds (Debian 12) from wkhtmltopdf's official packaging releases.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      wget ca-certificates fontconfig libxrender1 libxext6 libfreetype6 \
      libjpeg62-turbo libpng16-16 xfonts-base xfonts-75dpi gnupg; \
    ARCH="$(dpkg --print-architecture)"; \
    DEB="wkhtmltox_0.12.6.1-1.bookworm_${ARCH}.deb"; \
    wget -O /tmp/wkhtmltox.deb \
      "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1/${DEB}"; \
    apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb; \
    rm -f /tmp/wkhtmltox.deb; \
    apt-get clean; rm -rf /var/lib/apt/lists/*


# Copy Odoo config and optional Python deps
COPY odoo.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf && chmod 640 /etc/odoo/odoo.conf

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

# Render will set $PORT; Odoo default is 8069, we'll override at runtime
ENV PORT=8069
EXPOSE 8069

USER odoo

# Start Odoo with our config; DB/port are provided via CLI flags in Render Start Command
CMD ["odoo", "-c", "/etc/odoo/odoo.conf"]
