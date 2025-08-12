FROM python:3.10-slim


# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget curl git \
    python3-dev libxml2-dev libxslt1-dev zlib1g-dev \
    libsasl2-dev libldap2-dev libssl-dev libffi-dev \
    libjpeg-dev libpq-dev \
    xfonts-75dpi xfonts-base \
    nodejs npm \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Make sure we have apt utils
RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    fontconfig \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    libfreetype6 \
    libpng16-16 \
    libjpeg62-turbo \
    xfonts-base \
    xfonts-75dpi \
 && rm -rf /var/lib/apt/lists/*

# Copy Odoo source
COPY . /odoo
WORKDIR /odoo

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Create odoo user
RUN useradd -ms /bin/bash odoo
USER odoo

EXPOSE 8069

CMD ["python3", "odoo-bin", "-c", "/odoo.conf"]
