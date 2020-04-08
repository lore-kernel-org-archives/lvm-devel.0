From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  8 Apr 2020 13:37:46 +0000 (GMT)
Subject: master - test: repair of thin-pool used by foreign apps
Message-ID: <20200408133746.A8CED388700B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3dd11d9ea8b04a47e4eab7ebdd22c34fa18d4787
Commit:        3dd11d9ea8b04a47e4eab7ebdd22c34fa18d4787
Parent:        98e33ee3fbce8c43c312a2e6b8e42cddb3e6874c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 8 15:20:33 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 8 15:37:24 2020 +0200

test: repair of thin-pool used by foreign apps

---
 test/shell/thin-foreign-repair.sh | 72 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/test/shell/thin-foreign-repair.sh b/test/shell/thin-foreign-repair.sh
new file mode 100644
index 000000000..147a9a073
--- /dev/null
+++ b/test/shell/thin-foreign-repair.sh
@@ -0,0 +1,72 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# test foreing user of thin-pool
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+cleanup_mounted_and_teardown()
+{
+	dmsetup remove $THIN || true
+	vgremove -ff $vg
+	aux teardown
+}
+
+#
+# Main
+#
+aux have_thin 1 0 0 || skip
+which mkfs.ext4 || skip
+
+# Use our mkfs config file to get approximately same results
+# TODO: maybe use it for all test via some 'prepare' function
+export MKE2FS_CONFIG="$TESTOLDPWD/lib/mke2fs.conf"
+
+aux prepare_vg 2 64
+
+# Create named pool only
+lvcreate -L2 -T $vg/pool
+
+POOL="$vg-pool"
+THIN="${PREFIX}_thin"
+
+# Foreing user is using own ioctl command to create thin devices
+dmsetup message $POOL 0 "create_thin 0"
+dmsetup message $POOL 0 "set_transaction_id 0 2"
+
+# Once the transaction id has changed, lvm2 shall not be able to create thinLV
+fail lvcreate -V10 $vg/pool
+
+trap 'cleanup_mounted_and_teardown' EXIT
+
+# 20M thin device
+dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
+
+mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
+
+dmsetup remove "$THIN"
+
+lvchange -an $vg/pool
+
+# Repair thin-pool used by 'foreing' apps (setting their own tid)
+lvconvert --repair $vg/pool 2>&1 | tee out
+
+not grep "Transaction id" out
+
+lvchange -ay $vg/pool
+
+dmsetup create "$THIN" --table "0 40960 thin $DM_DEV_DIR/mapper/$POOL 0"
+
+fsck -n "$DM_DEV_DIR/mapper/$THIN"



