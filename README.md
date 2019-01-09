# TrailInsurance Salesforce Metadata

This repo contains the necessary Salesforce org configuration for use with the TrailInsurance demo iOS Application.

## Dev, Build and Test

To use TrailInsurance, you'll need to:

1. Push this metadata to a scratch org
2. Login to your scratch org and create a new connected app.
3. Ensure the connected app has the oAuth scopes of:

- Access your basic information (id, profile, email, address, phone)
- Access and manage your data (api)
  *Provide access to your data via the Web (web)
  *Access and manage your Chatter data (chatter_api)
- Perform requests on your behalf at any time (refresh_token, offline_access)

4. Copy the Consumer Key, you'll need to paste it into the bootconfig.plist file. Bootconfig.plist is found in the main iOS project folder.
