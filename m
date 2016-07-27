From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 Jul 2016 14:21:28 +0000 (UTC)
Subject: master - lvconvert: suppress zeroing warning when converting to thin
Message-ID: <20160727142129.4625D60AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5636bfd83d54f119d313603f4f9070bf0dfba2fe
Commit:        5636bfd83d54f119d313603f4f9070bf0dfba2fe
Parent:        f66ae6e80f37e83d6e71f93127b60978801dc445
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 27 13:36:25 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 27 16:20:57 2016 +0200

lvconvert: suppress zeroing warning when converting to thin

When volume was lvconvert-ed to a thin-volume with external origin,
then in case thin-pool was in non-zeroing mode
it's been printing WARNING about not zeroing thin volume - but
this is wanted and expected - so nothing to warn about.

So in this particular use case WARNING needs to be suppressed.

Adding parameter support for lvcreate_params.

So now lvconvert creates 'normal thin LV' in read-only mode
(so any read will 'return 0' for a moment)
then deactivate regular thin LV and reacreate in 'final R/RW' mode
thin LV with external origin and activate again.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    1 +
 tools/lvconvert.c                |    5 ++++-
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4f24476..abd9fb8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Suppress not zeroing warn when converting to thin LV for non-zeroing tpool.
   Fix automatic updates of PV extension headers to newest version.
   Improve lvconvert --trackchanges validation to require --splitmirrors 1.
   Add note about lastlog built-in command to lvm man page.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c6b8eb5..2a55be7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7592,7 +7592,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		goto deactivate_and_revert_new_lv;
 	}
 
-	if (_should_wipe_lv(lp, lv, 1)) {
+	if (_should_wipe_lv(lp, lv, !lp->suppress_zero_warn)) {
 		if (!wipe_lv(lv, (struct wipe_params)
 			     {
 				     .do_zero = lp->zero,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 37d4bf8..ff879bb 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -922,6 +922,7 @@ struct lvcreate_params {
 #define THIN_CHUNK_SIZE_CALC_METHOD_GENERIC 0x01
 #define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
 	int thin_chunk_size_calc_policy;
+	unsigned suppress_zero_warn : 1;
 	unsigned needs_lockd_init : 1;
 
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c0838d1..be7425f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2679,6 +2679,7 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		.lv_name = lp->origin_name,
 		.major = -1,
 		.minor = -1,
+		.suppress_zero_warn = 1, /* Suppress warning for this thin */
 		.permission = LVM_READ,
 		.pool_name = pool_lv->name,
 		.pvh = &vg->pvs,
@@ -2735,7 +2736,9 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	if (!archive(vg))
 		return_0;
 
-	/* New thin LV needs to be created (all messages sent to pool) */
+	/* New thin LV needs to be created (all messages sent to pool)
+	 * In this case thin volume is created READ-ONLY and
+	 * also warn about not zeroing is suppressed. */
 	if (!(torigin_lv = lv_create_single(vg, &lvc)))
 		return_0;
 


