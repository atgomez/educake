---
title: Authentication
---

<h1>Authentication with OAuth</h1>

All API endpoints require an OAuth access token. 

## OAuth

educake.co currently supports the [OAuth 2][1] draft specification. All OAuth2 requests MUST use the SSL endpoint available at `http://educake.co/api/:version` (SSL will be available)

OAuth 2.0 is a simple and secure authentication mechanism. It allows applications to acquire an access token for educake.co via a quick redirect to the educake.co site. Once an application has an access token, it can access a user's link metrics, and shorten links using that user's educake.co account. Authentication with OAuth can be accomplished in the following steps:

OAuth authentication is made by adding the `access_token` parameter with a users access token. All requests with OAuth tokens must be made over **SSL** to `http://educake.co/api/:version`.

    access_token=**access_token**
    

## OAuth Web Flow

Web applications can easily acquire an OAuth access token for a educake.co end user by following these steps:

*   Register your application [here][2] -- your application will be assigned a `client_id` (consumer_key) and a `client_secret` (consumer_secret).

*   Redirect the user to `http://educake.co/oauth/authorize`, using the `client_id` and `redirect_uri` parameters to pass your client ID and the page you would like to redirect to upon acquiring an access token. An example redirect URL looks like: `http://educake.co/oauth/authorize?client_id=...&redirect_uri=http://myexamplewebapp.com/oauth_page`

*   Upon authorizing your application, the user is directed to the page specified in the `redirect_uri` parameter. We append a `code` parameter to this URI, that contains a value that can be exchanged for an OAuth access token using the oauth/access_token endpoint documented below. For example, if you passed a `redirect_uri` value of `http://myexamplewebapp.com/oauth_page`, a successful authentication will redirect the user to `http://myexamplewebapp.com/oauth_page?code=....`

*   Use the /oauth/access_token API endpoint documented below to acquire an OAuth access token, passing the `code` value appended by educake.co to the previous redirect and the same `redirect_uri` value that was used previously. This API endpoint will return an OAuth access token, as well as the specified educake.co user's login and API key, allowing your application to utilize the educake.co API on that user's behalf.

    
 [1]: http://oauth.net/2/
 [2]: http://educake.co/oauth_clients/new