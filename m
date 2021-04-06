From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:27 +0000 (GMT)
Subject: main - mirror_percent: support interruptible check
Message-ID: <20210406200727.5AD683857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff8aaadec912398598fd4b16de99ed700b97b130
Commit:        ff8aaadec912398598fd4b16de99ed700b97b130
Parent:        1f17b1c56526abc7b7c8edacfba683b396f95705
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 6 14:47:11 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 22:02:31 2021 +0200

mirror_percent: support interruptible check

When checking for mirror percentage with WAITEVENT (i.e. during pvmove)
handle intrruption (^C) of such wait.
---
 lib/activate/dev_manager.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 172a6bab1..c4a673901 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -26,6 +26,7 @@
 #include "lib/activate/activate.h"
 #include "lib/misc/lvm-exec.h"
 #include "lib/datastruct/str_list.h"
+#include "lib/misc/lvm-signal.h"
 
 #include <limits.h>
 #include <dirent.h>
@@ -1123,7 +1124,8 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			const char *dlid,
 			const char *target_type, int wait,
 			const struct logical_volume *lv, dm_percent_t *overall_percent,
-			uint32_t *event_nr, int fail_if_percent_unsupported)
+			uint32_t *event_nr, int fail_if_percent_unsupported,
+			int *interrupted)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -1144,9 +1146,12 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 	if (!(segtype = get_segtype_from_string(dm->cmd, target_type)))
 		return_0;
 
+	if (wait)
+		sigint_allow();
+
 	if (!(dmt = _setup_task_run(wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, &info,
 				    name, dlid, event_nr, 0, 0, 0, 0, 0)))
-		return_0;
+		goto_bad;
 
 	if (!info.exists)
 		goto_out;
@@ -1214,8 +1219,19 @@ static int _percent_run(struct dev_manager *dm, const char *name,
 			     display_percent(dm->cmd, *overall_percent));
 	r = 1;
 
-      out:
+    out:
 	dm_task_destroy(dmt);
+
+    bad:
+	if (wait) {
+		sigint_restore();
+
+		if (sigint_caught()) {
+			*interrupted = 1;
+			return_0;
+		}
+	}
+
 	return r;
 }
 
@@ -1224,20 +1240,24 @@ static int _percent(struct dev_manager *dm, const char *name, const char *dlid,
 		    const struct logical_volume *lv, dm_percent_t *percent,
 		    uint32_t *event_nr, int fail_if_percent_unsupported)
 {
+	int interrupted = 0;
+
 	if (dlid && *dlid) {
 		if (_percent_run(dm, NULL, dlid, target_type, wait, lv, percent,
-				 event_nr, fail_if_percent_unsupported))
+				 event_nr, fail_if_percent_unsupported, &interrupted))
 			return 1;
 
-		if (_original_uuid_format_check_required(dm->cmd) &&
+		if (!interrupted &&
+		    _original_uuid_format_check_required(dm->cmd) &&
 		    _percent_run(dm, NULL, dlid + sizeof(UUID_PREFIX) - 1,
 				 target_type, wait, lv, percent,
-				 event_nr, fail_if_percent_unsupported))
+				 event_nr, fail_if_percent_unsupported, &interrupted))
 			return 1;
 	}
 
-	if (name && _percent_run(dm, name, NULL, target_type, wait, lv, percent,
-				 event_nr, fail_if_percent_unsupported))
+	if (!interrupted && name &&
+	    _percent_run(dm, name, NULL, target_type, wait, lv, percent,
+				 event_nr, fail_if_percent_unsupported, &interrupted))
 		return 1;
 
 	return_0;


