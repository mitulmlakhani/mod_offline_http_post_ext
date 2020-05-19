Ejabberd >= 17.01 module to send offline user's message via POST request to target URL.
This module can call an api to send e.g. a push message. 
The request body is in application/x-www-form-urlencoded format. See the example below.


Installation
------------

1. cd /opt/ejabberd-{your ejabbed version}/.ejabberd-module/sources/
2. git clone https://github.com/mitulmlakhani/mod_offline_http_post_ext.git;
3. bash /opt/ejabberd-{your ejabbed version}/.ejabberd-module/bin/ejabberdctl module-install mod_offline_http_post_ext
4. /etc/init.d/ejabberd restart;

Great, The module is now installed.

Configuration
-------------

Add the following to ejabberd configuration under `modules:`

```
mod_offline_http_post_ext:
    auth_token: "secret"
    post_url: "http://example.com/send_push"
```

-    auth_token - custom static token for authorize request.
-    post_url - your server's endpoint url

