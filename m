From: corubba <corubba@gmx.de>
Date: Tue, 1 Nov 2022 22:23:47 +0100
Subject: [PATCH v2 2/3] report: query lvmlockd for lv_active_exclusively
In-Reply-To: <9002aa3d-a523-7283-3a53-c9499add0cd6@gmx.de>
References: <9002aa3d-a523-7283-3a53-c9499add0cd6@gmx.de>
Message-ID: <ef4eac45-6e5e-06dd-fc9b-2794a261ab90@gmx.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Adjusted the lv_active_exclusively option to account for shared VGs.

A LV is definitely not exclusively active if:
- it is not (locally) active, regardless of whether it is in a local or
  shared VG.
- it is in a shared VG, locally active, and lvmlockd reports a
  non-exclusive lock (e.g. shared lock or no lock at all).

A LV is definitely exclusively active if:
- it is in a local VG, and (locally) active.
- it is in a shared VG, locally active, and lvmlockd reports a exclusive
  lock.

The "exclusively active" state of a LV is undefined if:
- it is in a shared VG, locally active, and lvmlockd can't be reached or
  responds with an error.

For the sanlock lvmlock LV, lvmlockd reports no lock and it is thus
shown as not exclusively active.

Signed-off-by: corubba <corubba@gmx.de>
---
v2: Rename and use the existing _query_lock_lv(...) function instead of
    reimplementing the whole lvmlockd communication.

 lib/locking/lvmlockd.c |  7 +++----
 lib/locking/lvmlockd.h |  9 +++++++++
 lib/report/report.c    | 10 +++++++++-
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 7f8150365..790dc70b7 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2298,9 +2298,8 @@ int lockd_vg_update(struct volume_group *vg)
 	return ret;
 }

-static int _query_lock_lv(struct cmd_context *cmd, struct volume_group *vg,
-			  const char *lv_name, char *lv_uuid,
-			  const char *lock_args, int *ex, int *sh)
+int lockd_query_lv(struct volume_group *vg, const char *lv_name, char *lv_uuid,
+		   const char *lock_args, int *ex, int *sh)
 {
 	daemon_reply reply;
 	const char *opts = NULL;
@@ -2386,7 +2385,7 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		    !strcmp(cmd->name, "lvchange") || !strcmp(cmd->name, "lvconvert")) {
 			int ex = 0, sh = 0;

-			if (!_query_lock_lv(cmd, vg, lv_name, lv_uuid, lock_args, &ex, &sh))
+			if (!lockd_query_lv(vg, lv_name, lv_uuid, lock_args, &ex, &sh))
 				return 1;
 			if (sh) {
 				log_warn("WARNING: shared LV may require refresh on other hosts where it is active.");
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 43934202f..fcaa0a326 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -103,6 +103,9 @@ int lockd_lv_uses_lock(struct logical_volume *lv);

 int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_params *lp);

+int lockd_query_lv(struct volume_group *vg, const char *lv_name, char *lv_uuid,
+		   const char *lock_args, int *ex, int *sh);
+
 #else /* LVMLOCKD_SUPPORT */

 static inline void lvmlockd_set_socket(const char *sock)
@@ -258,6 +261,12 @@ static inline int lockd_lv_refresh(struct cmd_context *cmd, struct lvresize_para
 	return 0;
 }

+static inline int lockd_query_lv(struct volume_group *vg, const char *lv_name,
+		  char *lv_uuid, const char *lock_args, int *ex, int *sh)
+{
+	return 0;
+}
+
 #endif	/* LVMLOCKD_SUPPORT */

 #endif	/* _LVMLOCKD_H */
diff --git a/lib/report/report.c b/lib/report/report.c
index cb5fc93c8..26d35ba95 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -24,6 +24,7 @@
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device-types.h"
 #include "lib/datastruct/str_list.h"
+#include "lib/locking/lvmlockd.h"

 #include <stddef.h> /* offsetof() */
 #include <float.h> /* DBL_MAX */
@@ -3854,13 +3855,20 @@ static int _lvactiveexclusively_disp(struct dm_report *rh, struct dm_pool *mem,
 				     const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	int active_exclusively;
+	int active_exclusively, _sh = 0;

 	if (!activation())
 		return _binary_undef_disp(rh, mem, field, private);

 	active_exclusively = lv_is_active(lv);

+	if (active_exclusively && vg_is_shared(lv->vg)) {
+		active_exclusively = 0;
+		if (!lockd_query_lv(lv->vg, lv->name, lv_uuid_dup(NULL, lv),
+				    lv->lock_args, &active_exclusively, &_sh))
+			return _binary_undef_disp(rh, mem, field, private);
+	}
+
 	return _binary_disp(rh, mem, field, active_exclusively, GET_FIRST_RESERVED_NAME(lv_active_exclusively_y), private);
 }

--
2.38.1

