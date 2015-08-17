From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 09:25:12 +0000 (UTC)
Subject: master - cache: use undefined settings for cache_policy
Message-ID: <20150817092512.18BBE6104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4c024c836aa10be0fe4d55157bac15f5ede62a8
Commit:        d4c024c836aa10be0fe4d55157bac15f5ede62a8
Parent:        b297d78367c2a9395bcc6abc7484763368979842
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 17 11:19:28 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 11:25:03 2015 +0200

cache: use undefined settings for cache_policy

As cache_policy is evaluated in runtime, we no longer should use
CFG_COMMENTED, but have to switch to CFG_UNDEFINED.

So as long as the value is undefined, it's runtime evaluated.
Once it's set - it's always respected (no runtime fallback).

Also fix version of introduced settings to 2.2.128.
---
 lib/config/config_settings.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b687c57..f18d173 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -474,13 +474,13 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_DEFAULT
 	"writeback - Data blocks are written from the cache back\n"
 	"to disk after some delay to improve performance.\n")
 
-cfg_runtime(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, vsn(2, 2, 127), 0, NULL,
+cfg_runtime(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, vsn(2, 2, 128), 0, NULL,
 	"The default cache policy used for new cache volume.\n"
-	"Generally available policies are: mq, smq.\n"
-	"mq  - Multiqueue policy with 88 bytes per block\n"
-	"smq - Stochastic multique with 25 bytes per block (kernel >= 4.2).\n")
+	"For the kernel 4.2 and newer the default policy is smq\n"
+	"(Stochastic multique), otherwise the older mq (Multiqueue),\n"
+	"policy is selected.\n")
 
-cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 127), 0, NULL,
+cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
 	"Individual settings for policies.\n"
 	"See the help for individual policies for more info.\n")
 


