From: Milan Broz <mbroz@redhat.com>
Date: Tue, 24 Nov 2009 13:40:18 +0100
Subject: [PATCH] Move persistent filter dump to more appropriate place.
Message-ID: <1259066418-25100-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

After context_refresh is cache empty, the cache flush
does nothing.

Call it after lvmcache full rescan if running from
log lived process.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c       |    8 ++++++++
 lib/commands/toolcontext.c |    7 -------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index bfb714c..672b4b1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -20,6 +20,7 @@
 #include "locking.h"
 #include "metadata.h"
 #include "filter.h"
+#include "filter-persistent.h"
 #include "memlock.h"
 #include "str_list.h"
 #include "format-text.h"
@@ -533,6 +534,13 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 			goto out;
 	}
 
+	/*
+	 * If we are a long-lived process, write out the updated persistent
+	 * device cache for the benefit of short-lived processes.
+	 */
+	if (full_scan == 2 && cmd->is_long_lived && cmd->dump_filter)
+		persistent_filter_dump(cmd->filter);
+
 	r = 1;
 
       out:
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 721c2cf..80b6f8f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1291,13 +1291,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_segtypes(cmd))
 		return 0;
 
-	/*
-	 * If we are a long-lived process, write out the updated persistent
-	 * device cache for the benefit of short-lived processes.
-	 */
-	if (cmd->is_long_lived && cmd->dump_filter)
-		persistent_filter_dump(cmd->filter);
-
 	cmd->config_valid = 1;
 
 	reset_lvm_errno(1);
-- 
1.6.5.3


