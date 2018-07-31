From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Jul 2018 08:57:21 -0400
Subject: 2018-06-01-stable - dmeventd: rebase to stable branch
Message-ID: <201807311257.w6VCvLal000625@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7645995da292678cf49528ca618ecc8cd3f31b4
Commit:        f7645995da292678cf49528ca618ecc8cd3f31b4
Parent:        4ed9b0738022d32ecd7d3fffc89df89d48869df1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 27 11:17:26 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 31 14:55:03 2018 +0200

dmeventd: rebase to stable branch

Some minimal set of changes to make vdo plugin compilable in stable branch:

Use older headers.
Implement simple vdo status parser to only resolve use-percentage.
---
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c |   39 ++++++++++++++++++---------
 1 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index d77ca79..389632c 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -12,10 +12,9 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib/misc/lib.h"
+#include "lib.h"
 #include "dmeventd_lvm.h"
-#include "daemons/dmeventd/libdevmapper-event.h"
-#include "device_mapper/vdo/target.h"
+#include "libdevmapper-event.h"
 
 #include <sys/wait.h>
 #include <stdarg.h>
@@ -46,6 +45,23 @@ struct dso_state {
 	const char *name;
 };
 
+struct vdo_status {
+	uint64_t used_blocks;
+	uint64_t total_blocks;
+};
+
+static int _vdo_status_parse(const char *params, struct vdo_status *status)
+{
+	if (sscanf(params, "%*s %*s %*s %*s %*s %" PRIu64 " %" PRIu64,
+		   &status->used_blocks,
+		   &status->total_blocks) < 2) {
+		log_error("Failed to parse vdo params: %s.", params);
+		return 0;
+	}
+
+	return 1;
+}
+
 DM_EVENT_LOG_FN("vdo")
 
 static int _run_command(struct dso_state *state)
@@ -149,7 +165,7 @@ void process_event(struct dm_task *dmt,
 	char *params;
 	int needs_policy = 0;
 	struct dm_task *new_dmt = NULL;
-	struct dm_vdo_status_parse_result vdop = { .status = NULL };
+	struct vdo_status status;
 
 #if VDO_DEBUG
 	log_debug("Watch for VDO %s:%.2f%%.", state->name,
@@ -195,24 +211,24 @@ void process_event(struct dm_task *dmt,
 		goto out;
 	}
 
-	if (!dm_vdo_status_parse(state->mem, params, &vdop)) {
+	if (!_vdo_status_parse(params, &status)) {
 		log_error("Failed to parse status.");
 		goto out;
 	}
 
-	state->percent = dm_make_percent(vdop.status->used_blocks,
-					 vdop.status->total_blocks);
+	state->percent = dm_make_percent(status.used_blocks,
+					 status.total_blocks);
 
 #if VDO_DEBUG
 	log_debug("VDO %s status  %.2f%% " FMTu64 "/" FMTu64 ".",
 		  state->name, dm_percent_to_round_float(state->percent, 2),
-		  vdop.status->used_blocks, vdop.status->total_blocks);
+		  status.used_blocks, status.total_blocks);
 #endif
 
 	/* VDO pool size had changed. Clear the threshold. */
-	if (state->known_data_size != vdop.status->total_blocks) {
+	if (state->known_data_size != status.total_blocks) {
 		state->percent_check = CHECK_MINIMUM;
-		state->known_data_size = vdop.status->total_blocks;
+		state->known_data_size = status.total_blocks;
 		state->fails = 0;
 	}
 
@@ -257,9 +273,6 @@ void process_event(struct dm_task *dmt,
 	if (0 && needs_policy)
 		_use_policy(dmt, state);
 out:
-	if (vdop.status)
-		dm_pool_free(state->mem, vdop.status);
-
 	if (new_dmt)
 		dm_task_destroy(new_dmt);
 }


