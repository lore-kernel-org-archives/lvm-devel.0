From: Milan Broz <mbroz@redhat.com>
Date: Sun, 25 Mar 2012 22:56:04 +0200
Subject: [PATCH 2/4] Use new flag PVMOVE_EXCLUSIVE in update_metatada call.
In-Reply-To: <cover.1332708600.git.mbroz@redhat.com>
References: <cover.1332708600.git.mbroz@redhat.com>
Message-ID: <8f0c21362f5fd0a8482466a594e80e7526b34eb1.1332708600.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is no real functional change in this patch except it
avoids checking cluster cmirror module twice.

(Flag used in following patch.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/pvmove.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 8d543b0..40ef069 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -18,6 +18,7 @@
 #include "display.h"
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
+#define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
 
 static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 {
@@ -358,7 +359,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
 			    struct dm_list *lvs_changed, unsigned flags)
 {
-	unsigned exclusive = _pvmove_is_exclusive(cmd, vg);
+	unsigned exclusive = (flags & PVMOVE_EXCLUSIVE) ? 1 : 0;
 	unsigned first_time = (flags & PVMOVE_FIRST_TIME) ? 1 : 0;
 	int r = 0;
 
@@ -390,6 +391,9 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	/* Only the first mirror segment gets activated as a mirror */
 	/* FIXME: Add option to use a log */
 	if (first_time) {
+		if (!exclusive && _pvmove_is_exclusive(cmd, vg))
+			exclusive = 1;
+
 		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
 			if (test_mode()) {
 				r = 1;
@@ -428,7 +432,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	struct dm_list *lvs_changed;
 	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
-	unsigned first_time = 1;
+	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
 	int r = ECMD_FAILED;
 
@@ -485,7 +489,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 			goto out;
 		}
 
-		first_time = 0;
+		flags &= ~PVMOVE_FIRST_TIME;
 	} else {
 		/* Determine PE ranges to be moved */
 		if (!(source_pvl = create_pv_list(cmd->mem, vg, 1,
@@ -518,9 +522,11 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* init_pvmove(1); */
 	/* vg->status |= PVMOVE; */
 
-	if (first_time) {
+	if (flags & PVMOVE_FIRST_TIME) {
+		if (exclusive)
+			flags |= PVMOVE_EXCLUSIVE;
 		if (!_update_metadata
-		    (cmd, vg, lv_mirr, lvs_changed, PVMOVE_FIRST_TIME))
+		    (cmd, vg, lv_mirr, lvs_changed, flags))
 			goto_out;
 	}
 
-- 
1.7.9.1


