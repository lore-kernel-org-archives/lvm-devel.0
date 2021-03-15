From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:02 +0000 (GMT)
Subject: main - activation: use interruptible_usleep
Message-ID: <20210315101402.5E5E13858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3bb8f2ec195fcfbea599d6efa784cb5cbd39741
Commit:        a3bb8f2ec195fcfbea599d6efa784cb5cbd39741
Parent:        941f67ed09155011f13bb75db6aed621f94e2374
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 20:50:39 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

activation: use interruptible_usleep

Support interruption while waiting on device close.
---
 lib/activate/activate.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 4452d4d40..93ab30424 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -29,6 +29,7 @@
 #include "lib/metadata/segtype.h"
 #include "lib/misc/sharedlib.h"
 #include "lib/metadata/metadata.h"
+#include "lib/misc/lvm-signal.h"
 
 #include <limits.h>
 #include <fcntl.h>
@@ -863,25 +864,24 @@ int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used)
 	}
 
 	open_count_check_retries = retry_deactivation() ? OPEN_COUNT_CHECK_RETRIES : 1;
-	while (info.open_count > 0 && open_count_check_retries--) {
-		if (!open_count_check_retries) {
-			if (error_if_used)
-				log_error("Logical volume %s in use.", display_lvname(lv));
-			else
-				log_debug_activation("Logical volume %s in use.", display_lvname(lv));
-			return 0;
-		}
+	while (open_count_check_retries--) {
+		if (interruptible_usleep(OPEN_COUNT_CHECK_USLEEP_DELAY))
+			break;  /* interrupted */
 
-		usleep(OPEN_COUNT_CHECK_USLEEP_DELAY);
 		log_debug_activation("Retrying open_count check for %s.",
 				     display_lvname(lv));
-		if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0)) {
+		if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) || !info.exists) {
 			stack; /* device dissappeared? */
-			break;
-		}
+			return 1;
+		} else if (!info.open_count)
+			return 1;
 	}
 
-	return 1;
+	if (error_if_used)
+		log_error("Logical volume %s in use.", display_lvname(lv));
+	else
+		log_debug_activation("Logical volume %s in use.", display_lvname(lv));
+	return 0;
 }
 
 /*


