From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 15:27:57 +0000 (UTC)
Subject: master - cache: more comments for new setting
Message-ID: <20150817152757.C96D160F49@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80bc87e377cbcc10225e1d2b58d6e84b65b449de
Commit:        80bc87e377cbcc10225e1d2b58d6e84b65b449de
Parent:        77357081c8143d13d02aa0b7d5eb044a29aa65c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 17 17:26:39 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 17:26:39 2015 +0200

cache: more comments for new setting

---
 WHATS_NEW                    |    1 +
 lib/config/config_settings.h |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7508794..8e6ca10 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Allocation setting cache_pool_cachemode is replaced by cache_mode.
   Don't attempt to close config file that couldn't be opened.
   Check for valid cache mode in validation of cache segment.
   Change internal interface handling cache mode and policy.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index bdf7e6c..399f748 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -472,7 +472,8 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILA
 	"writethrough - Data blocks are immediately written from\n"
 	"the cache to disk.\n"
 	"writeback - Data blocks are written from the cache back\n"
-	"to disk after some delay to improve performance.\n")
+	"to disk after some delay to improve performance.\n"
+	"This setting replaces allocation/cache_pool_cachemode.\n")
 
 cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache policy used for new cache volume.\n"


