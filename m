From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 10:59:25 -0400
Subject: master - conf: update conf
Message-ID: <201805151459.w4FExPNn030342@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=889558fedb0f31d754ce146ac0858db1d5613543
Commit:        889558fedb0f31d754ce146ac0858db1d5613543
Parent:        d25c135806593146e70a7c9f7c44535fbeec49f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 16:58:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 16:58:28 2018 +0200

conf: update conf

Matching patch 2eba7c77557655cfbd19f191ec5d1ad1025897b3
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d8db7df..f49709c 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -768,7 +768,7 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"the error messages.\n")
 
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(1, 0, 18), NULL, 0, NULL,
-	"This setting setting no longer used.\n")
+	"This setting is no longer used.\n")
 
 cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, 0, NULL,
 	"This setting is no longer used.\n")


