From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Aug 2022 11:34:12 +0000 (GMT)
Subject: main - lvconvert: correct test support for vdo-pool
Message-ID: <20220815113412.2183B3858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0697be5004af0e040b1f746e619b8075350bc46
Commit:        d0697be5004af0e040b1f746e619b8075350bc46
Parent:        12ffa753f64eeea946e5331e64ed9d561de98c6b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 11 11:44:58 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 15 13:32:55 2022 +0200

lvconvert: correct test support for vdo-pool

---
 WHATS_NEW                | 1 +
 lib/metadata/vdo_manip.c | 4 +++-
 tools/lvconvert.c        | 4 +++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f77f25fe6..6a12e848f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Fix lvconvert --test --type vdo-pool execution.
   Add json_std output format for more JSON standard compliant version of output.
   Fix vdo_slab_size_mb value for converted VDO volume.
 
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 250080b25..4ccde40b1 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -424,7 +424,9 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 
 	/* Format data LV as VDO volume */
 	if (format) {
-		if (!_format_vdo_pool_data_lv(data_lv, vtp, &vdo_logical_size)) {
+		if (test_mode()) {
+			log_verbose("Test mode: Skipping formating of VDO pool volume.");
+		} else if (!_format_vdo_pool_data_lv(data_lv, vtp, &vdo_logical_size)) {
 			log_error("Cannot format VDO pool volume %s.", display_lvname(data_lv));
 			return NULL;
 		}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 76bef806c..081b344d0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5480,7 +5480,9 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 	}
 
 	if (vdo_pool_zero) {
-		if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
+		if (test_mode()) {
+			log_verbose("Test mode: Skipping activation, zeroing and signature wiping.");
+		} else if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
 			     .yes = arg_count(cmd, yes_ARG),
 			     .force = arg_count(cmd, force_ARG)})) {
 			log_error("Aborting. Failed to wipe VDO data store.");

