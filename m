From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:28 +0000 (UTC)
Subject: dev-mornfall-lvmcache - activation: fix lv_is_active regressions
Message-ID: <20130605120328.A10D360F76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f12d88f840474a75a58d1f7ae8d391ec5852b850
Commit:        f12d88f840474a75a58d1f7ae8d391ec5852b850
Parent:        2fbe1e6e00fc59f54ae11c19d51f2d7fc8425b16
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 15 02:13:31 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 15 02:13:31 2013 +0100

activation: fix lv_is_active regressions

Try to fix commit bf2741376d47411994d4065863acab8e405ff5c7.

lv_is_active is not the same as lv_info(cmd, org, 0, &info, 0, 0).

Introduce and use lv_is_active_locally.
---
 WHATS_NEW               |    2 +-
 lib/activate/activate.c |   11 +++++++++++
 lib/activate/activate.h |    1 +
 lib/metadata/lv_manip.c |   12 +++++++++++-
 lib/metadata/mirror.c   |    5 +++--
 lib/report/report.c     |    2 +-
 6 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0c7db4b..aa1a1c0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -115,7 +115,7 @@ Version 2.02.99 -
   Support use of option --yes for lvchange --persistent.
   Fix memory leak on error path for pvcreate with invalid uuid.
   Implement ref-counting for parents in python lib.
-  Use lv_is_active() instead of lv_info() call.
+  Add lv_is_active_locally and use instead of most local lv_info calls.
   Reduce some log_error messages to log_warn where we don't fail.
   Remove python liblvm object. systemdir can only be changed using env var now.
   
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 05cfb66..1174ce2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -274,6 +274,10 @@ int lv_is_active(const struct logical_volume *lv)
 {
 	return 0;
 }
+int lv_is_active_locally(const struct logical_volume *lv)
+{
+	return 0;
+}
 int lv_is_active_but_not_locally(const struct logical_volume *lv)
 {
 	return 0;
@@ -1252,6 +1256,13 @@ int lv_is_active(const struct logical_volume *lv)
 	return _lv_is_active(lv, NULL, NULL);
 }
 
+int lv_is_active_locally(const struct logical_volume *lv)
+{
+	int l;
+
+	return _lv_is_active(lv, &l, NULL) && l;
+}
+
 int lv_is_active_but_not_locally(const struct logical_volume *lv)
 {
 	int l;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index f7c312f..e80115a 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -134,6 +134,7 @@ int lvs_in_vg_activated(const struct volume_group *vg);
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(const struct logical_volume *lv);
+int lv_is_active_locally(const struct logical_volume *lv);
 int lv_is_active_but_not_locally(const struct logical_volume *lv);
 int lv_is_active_exclusive(const struct logical_volume *lv);
 int lv_is_active_exclusive_locally(const struct logical_volume *lv);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 42e0fab..ae86472 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4394,6 +4394,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
 	const char *thin_name = NULL;
+	int origin_active = 0;
+	struct lvinfo info;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -4523,7 +4525,15 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
-			if (vg_is_clustered(vg) && lv_is_active(org) &&
+			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
+				log_error("Check for existence of active snapshot "
+					  "origin '%s' failed.", org->name);
+				return NULL;
+			}
+
+			origin_active = info.exists;
+
+			if (vg_is_clustered(vg) &&
 			    !lv_is_active_exclusive_locally(org)) {
 				log_error("%s must be active exclusively to"
 					  " create snapshot", org->name);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 18d0d33..b93d73c 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -298,12 +298,13 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 	/* If the LV is active, deactivate it first. */
 	if (lv_is_active(log_lv)) {
+		(void) deactivate_lv(cmd, log_lv);
 		/*
 		 * FIXME: workaround to fail early
 		 * Ensure that log is really deactivated because deactivate_lv
 		 * on cluster do not fail if there is log_lv with different UUID.
 		 */
-		if (!deactivate_lv(cmd, log_lv)) {
+		if (lv_is_active(log_lv)) {
 			log_error("Aborting. Unable to deactivate mirror log.");
 			goto revert_new_lv;
 		}
@@ -1707,7 +1708,7 @@ int remove_mirror_log(struct cmd_context *cmd,
 	}
 
 	/* Had disk log, switch to core. */
-	if (lv_is_active(lv)) {
+	if (lv_is_active_locally(lv)) {
 		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent,
 				       NULL)) {
 			log_error("Unable to determine mirror sync status.");
diff --git a/lib/report/report.c b/lib/report/report.c
index 27c9708..d661596 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -866,7 +866,7 @@ static int _snpercent_disp(struct dm_report *rh __attribute__((unused)), struct
 	}
 
 	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
-	    !lv_is_active(lv)) {
+	    !lv_is_active_locally(lv)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;


