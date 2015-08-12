From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:40:55 +0000 (UTC)
Subject: master - cache: runtime detect default policy
Message-ID: <20150812124055.EC60061086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=feb8e9a7907c91bd55769b4e3ae625434f2ba589
Commit:        feb8e9a7907c91bd55769b4e3ae625434f2ba589
Parent:        8a74d1ec79d209aa8bce51821836179afe7d48f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 26 23:05:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:17 2015 +0200

cache: runtime detect default policy

When the policy is not preset in lvm.conf,
detect in runtime whether to use 'mq' or
new available 'smq'.
---
 WHATS_NEW           |    1 +
 lib/config/config.c |   22 +++++++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 347fcd4..da0ef4d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Runtime detect presence of cache smq policy.
   Add demo cache-mq  and cache-smq profiles.
   Add cmd profilable allocation/cache_policy,cache_settings,cache_mode.
   Require cache_check 0.5.4 for use of --clear-needs-check-flag.
diff --git a/lib/config/config.c b/lib/config/config.c
index 436efff..cd6c1d8 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -23,6 +23,7 @@
 #include "toolcontext.h"
 #include "lvm-file.h"
 #include "memlock.h"
+#include "segtype.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -2418,5 +2419,24 @@ int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, st
 
 const char *get_default_allocation_cache_policy_CFG(struct cmd_context *cmd, struct profile *profile)
 {
-	return DEFAULT_CACHE_POLICY;
+	const struct segment_type *segtype = get_segtype_from_string(cmd, "cache");
+	unsigned attr = ~0;
+
+	if (!segtype ||
+	    !segtype->ops->target_present ||
+	    !segtype->ops->target_present(cmd, NULL, &attr)) {
+		log_warn("WARNING: Cannot detect default cache policy, using \""
+			 DEFAULT_CACHE_POLICY "\".");
+		return DEFAULT_CACHE_POLICY;
+	}
+
+	if (attr & CACHE_FEATURE_POLICY_SMQ)
+		return "smq";
+
+	if (attr & CACHE_FEATURE_POLICY_MQ)
+		return "mq";
+
+	log_warn("WARNING: Default cache policy not available.");
+
+	return NULL;
 }


