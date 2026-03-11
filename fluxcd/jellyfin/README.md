I'm using an LDAP integration plugin for Jellyfin, with a corresponding Authentik LDAP Outpost. SSO is not desirable here since it is unlikely TV / mobile apps will be able to support the SSO flow.

I don't have a way to manage this plugin declaratively at this point. I could make a custom Jellyfin image that comes with the plugin maybe. But even then, it may be tricky to manage the configuration for the plugin itself.

So, here are the non-default settings for the LDAP plugin:  
LDAP server: `ak-outpost-ldap.authentik.svc.cluster.local`  
LDAP bind user: `cn=jellyfin-bind,ou=users,dc=ldap,dc=goauthentik,dc=io`  
LDAP base DN: `dc=ldap,dc=goauthentik,dc=io`  
LDAP search filter: `(memberOf=cn=JellyfinUsers,ou=groups,dc=ldap,dc=goauthentik,dc=io)`