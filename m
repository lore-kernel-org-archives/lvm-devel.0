From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2017 09:41:29 -0400
Subject: master - dmeventd: restore multiple warnings
Message-ID: <201705101341.v4ADfTEu005107@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=455a4de090f10f98ac2932a2540a30b7fdc34f61
Commit:        455a4de090f10f98ac2932a2540a30b7fdc34f61
Parent:        a9940d16fe5251f2f1d7cb008cfd3be1bfb50120
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 19 19:57:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:39:36 2017 +0200

dmeventd: restore multiple warnings

With recent updates for thin pool monitoring in version 169
we lost multiple WARNINGs to be printed in syslog, when
pool crossed  80%, 85%, 90%, 95%, 100%.

Restore this logic as we want to keep user informed more
then just once when 80% boundary is passed.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   12 +---
 test/shell/thin-dmeventd-warns.sh             |   85 +++++++++++++++++++++++++
 3 files changed, 90 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a8b721c..2894d62 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  Restore Warning by 5% increment when thin-pool is over 80% (1.02.138).
 
 Version 1.02.140 - 3rd May 2017
 ===============================
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index e7d24c5..7fd7b0e 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -47,10 +47,8 @@ struct dso_state {
 	struct dm_pool *mem;
 	int metadata_percent_check;
 	int metadata_percent;
-	int metadata_warn_once;
 	int data_percent_check;
 	int data_percent;
-	int data_warn_once;
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	unsigned fails;
@@ -253,9 +251,8 @@ void process_event(struct dm_task *dmt,
 	 * action is called for:  >50%, >55% ... >95%, 100%
 	 */
 	state->metadata_percent = dm_make_percent(tps->used_metadata_blocks, tps->total_metadata_blocks);
-	if (state->metadata_percent <= WARNING_THRESH)
-		state->metadata_warn_once = 0; /* Dropped bellow threshold, reset warn once */
-	else if (!state->metadata_warn_once++) /* Warn once when raised above threshold */
+	if ((state->metadata_percent > WARNING_THRESH) &&
+	    (state->metadata_percent > state->metadata_percent_check))
 		log_warn("WARNING: Thin pool %s metadata is now %.2f%% full.",
 			 device, dm_percent_to_float(state->metadata_percent));
 	if (state->metadata_percent > CHECK_MINIMUM) {
@@ -269,9 +266,8 @@ void process_event(struct dm_task *dmt,
 		state->metadata_percent_check = CHECK_MINIMUM;
 
 	state->data_percent = dm_make_percent(tps->used_data_blocks, tps->total_data_blocks);
-	if (state->data_percent <= WARNING_THRESH)
-		state->data_warn_once = 0;
-	else if (!state->data_warn_once++)
+	if ((state->data_percent > WARNING_THRESH) &&
+	    (state->data_percent > state->data_percent_check))
 		log_warn("WARNING: Thin pool %s data is now %.2f%% full.",
 			 device, dm_percent_to_float(state->data_percent));
 	if (state->data_percent > CHECK_MINIMUM) {
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
new file mode 100644
index 0000000..d22863b
--- /dev/null
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -0,0 +1,85 @@
+#!/bin/sh
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# test if dmeventd produces multiple warnings when pools runs above 80%
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_CLVMD=1
+SKIP_WITH_LVMETAD=1
+
+. lib/inittest
+
+which blkdiscard || skip
+
+percent_() {
+	get lv_field $vg/pool data_percent | cut -d. -f1
+}
+
+wait_warn_() {
+
+	for i in $(seq 1 7)
+	do
+		test $(egrep "WARNING: Thin pool.*is now" debug.log_DMEVENTD_out | wc -l) -eq $1 && return 0
+		sleep 2
+	done
+
+	die "Waiting too log for dmeventd log warning"
+}
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+
+aux prepare_dmeventd
+aux prepare_vg
+
+lvcreate -L8 -V8 -T $vg/pool -n $lv1
+
+
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=26
+test $(percent_) -gt 80
+
+# Give it some time to dmeventd to log WARNING
+wait_warn_ 1
+
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30
+test $(percent_) -gt 90
+
+# Give it some time to dmeventd to log WARNING
+wait_warn_ 2
+
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=8
+test $(percent_) -eq 100
+
+wait_warn_ 3
+
+blkdiscard "$DM_DEV_DIR/$vg/$lv1"
+
+# FIXME: Enforce thin-pool metadata commit with flushing status
+dmsetup status ${vg}-pool-tpool
+# Wait for thin-pool monitoring to notice lower values
+sleep 11
+# ATM dmeventd is not logging event for thin-pool getting
+# below 'WARNED' threshold.
+
+
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30
+test $(percent_) -gt 90
+
+lvs -a $vg
+dmsetup status ${vg}-pool-tpool
+
+# Check pool again Warns
+wait_warn_ 4
+
+vgremove -f $vg


