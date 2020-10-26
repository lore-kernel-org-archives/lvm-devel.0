From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Oct 2020 20:49:14 +0000 (GMT)
Subject: master - writecache: disallow partial or degraded activation
Message-ID: <20201026204914.A87CD3945C15@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=020d1edaa06e5e05b58e8d39530408f86a22d1b8
Commit:        020d1edaa06e5e05b58e8d39530408f86a22d1b8
Parent:        830c20d33cc8253c397e927291d51c249c2c0eb3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 26 15:35:23 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 26 15:48:58 2020 -0500

writecache: disallow partial or degraded activation

when either main or fast lvs are incomplete
---
 lib/activate/activate.c       |  8 ++++++++
 test/shell/writecache-misc.sh | 29 +++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 311d33a52..7ed644113 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2530,6 +2530,14 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 		}
 	}
 
+	if ((cmd->partial_activation || cmd->degraded_activation) && lv_is_writecache(lv)) {
+		struct logical_volume *lv_fast = first_seg(lv)->writecache;
+		if (lv_is_partial(lv) || (lv_fast && lv_is_partial(lv_fast))) {
+			log_error("Cannot use partial or degraded activation with writecache.");
+			goto out;
+		}
+	}
+
 	if (lv_has_unknown_segments(lv)) {
 		log_error("Refusing activation of LV %s containing "
 			  "an unrecognised segment.", display_lvname(lv));
diff --git a/test/shell/writecache-misc.sh b/test/shell/writecache-misc.sh
index 75364e5b3..80b793256 100644
--- a/test/shell/writecache-misc.sh
+++ b/test/shell/writecache-misc.sh
@@ -77,5 +77,34 @@ pvmove -n $vg/$lv1 "$dev3" "$dev1"
 
 mount_umount $lv1
 lvchange -an $vg/$lv1
+lvremove -y $vg/$lv1
+
+
+#
+# Test partial and degraded activation
+#
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev2"
+lvcreate -n $lv2 -l 16 -an $vg "$dev3" "$dev4"
+
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+lvs -a -o+devices $vg
+lvchange -an $vg/$lv1
+
+aux hide_dev "$dev1"
+not lvchange -ay $vg/$lv1
+not lvchange -ay --partial $vg/$lv1
+not lvchange -ay --activationmode degraded $vg/$lv1
+aux unhide_dev "$dev1"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+
+aux hide_dev "$dev3"
+not lvchange -ay $vg/$lv1
+not lvchange -ay --partial $vg/$lv1
+not lvchange -ay --activationmode degraded $vg/$lv1
+aux unhide_dev "$dev3"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
 
 vgremove -ff $vg


