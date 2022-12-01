From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  1 Dec 2022 07:21:34 +0000 (GMT)
Subject: rhel-8.8.0 - lvconvert: correct test support for vdo-pool
Message-ID: <20221201072134.4C4633858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73943825501daede9963bb5d15abbc4d36febb40
Commit:        73943825501daede9963bb5d15abbc4d36febb40
Parent:        87904fbbb84c10e6f733db1c5ba447537d1cf08c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 11 11:44:58 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Nov 28 17:11:21 2022 +0100

lvconvert: correct test support for vdo-pool

(cherry picked from commit d0697be5004af0e040b1f746e619b8075350bc46)
---
 WHATS_NEW                | 4 ++++
 lib/metadata/vdo_manip.c | 4 +++-
 tools/lvconvert.c        | 4 +++-
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 240234e4d..e626802ec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,7 @@
+Version 2.03.17 - 
+===============================
+  Fix lvconvert --test --type vdo-pool execution.
+
 Version 2.03.14 - 20th October 2021
 ===================================
   Device scanning is skipping directories on different filesystems.
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index fa9c893cb..11a119a68 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -392,7 +392,9 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 
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
index 3d4b24fe3..c1d373318 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5482,7 +5482,9 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 	}
 
 	if (vdo_pool_zero) {
-		if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
+		if (test_mode()) {
+			log_verbose("Test mode: Skipping activation, zeroing and signature wiping.");
+		} else if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1, .do_wipe_signatures = 1,
 			     .yes = arg_count(cmd, yes_ARG),
 			     .force = arg_count(cmd, force_ARG)})) {
 			log_error("Aborting. Failed to wipe VDO data store.");

