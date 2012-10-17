From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Oct 2012 13:43:29 +0000 (UTC)
Subject: master - Use lv_is_active instead of lv_info()
Message-ID: <20121017134329.F19371F38@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf2741376d47411994d4065863acab8e405ff5c7
Commit:        bf2741376d47411994d4065863acab8e405ff5c7
Parent:        e431b19bac29cf8fc21530118eb283b6ae703cbb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 31 23:42:53 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 17 15:42:31 2012 +0200

Use lv_is_active instead of lv_info()

Usage of lv_is_active makes it more obvious what is being checked.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    5 ++---
 lib/metadata/mirror.c   |    9 +++------
 lib/report/report.c     |    3 +--
 4 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 370c7e5..8ba9f2d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Use lv_is_active() instead of lv_info() call.
   Cleanup some log_error message and use log_warn instead.
   
 Version 2.02.98 - 15th October 2012
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d2aca00..32a207d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4218,7 +4218,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
 	int origin_active = 0;
-	struct lvinfo info;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -4350,12 +4349,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
-			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
+			if (!lv_is_active(org)) {
 				log_error("Check for existence of active snapshot "
 					  "origin '%s' failed.", org->name);
 				return NULL;
 			}
-			origin_active = info.exists;
+			origin_active = 1;
 
 			if (vg_is_clustered(vg) &&
 			    !lv_is_active_exclusive_locally(org)) {
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c4683df..084c93a 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -282,7 +282,6 @@ static int _init_mirror_log(struct cmd_context *cmd,
 			    struct dm_list *tags, int remove_on_failure)
 {
 	struct str_list *sl;
-	struct lvinfo info;
 	uint64_t orig_status = log_lv->status;
 	int was_active = 0;
 
@@ -298,14 +297,13 @@ static int _init_mirror_log(struct cmd_context *cmd,
 	}
 
 	/* If the LV is active, deactivate it first. */
-	if (lv_info(cmd, log_lv, 0, &info, 0, 0) && info.exists) {
-		(void)deactivate_lv(cmd, log_lv);
+	if (lv_is_active(log_lv)) {
 		/*
 		 * FIXME: workaround to fail early
 		 * Ensure that log is really deactivated because deactivate_lv
 		 * on cluster do not fail if there is log_lv with different UUID.
 		 */
-		if (lv_info(cmd, log_lv, 0, &info, 0, 0) && info.exists) {
+		if (!deactivate_lv(cmd, log_lv)) {
 			log_error("Aborting. Unable to deactivate mirror log.");
 			goto revert_new_lv;
 		}
@@ -1714,7 +1712,6 @@ int remove_mirror_log(struct cmd_context *cmd,
 		      int force)
 {
 	percent_t sync_percent;
-	struct lvinfo info;
 	struct volume_group *vg = lv->vg;
 
 	/* Unimplemented features */
@@ -1724,7 +1721,7 @@ int remove_mirror_log(struct cmd_context *cmd,
 	}
 
 	/* Had disk log, switch to core. */
-	if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
+	if (lv_is_active(lv)) {
 		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent,
 				       NULL)) {
 			log_error("Unable to determine mirror sync status.");
diff --git a/lib/report/report.c b/lib/report/report.c
index eeca282..b1e2bc1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -830,7 +830,6 @@ static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct
 			   const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
 	percent_t snap_percent;
 	uint64_t *sortval;
 	char *repstr;
@@ -847,7 +846,7 @@ static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct
 	}
 
 	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
-	    !lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) || !info.exists) {
+	    !lv_is_active(lv)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;


