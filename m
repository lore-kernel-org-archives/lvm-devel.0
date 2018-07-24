From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 24 Jul 2018 14:41:46 -0400
Subject: master - test: new lvcreate-raid1-error-read.sh
Message-ID: <201807241841.w6OIfkLT027129@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f43f0393e9d7b85578895aa2e31314a4565e47d
Commit:        2f43f0393e9d7b85578895aa2e31314a4565e47d
Parent:        706606627f9b1ca75bb49466ae9aee04d858c2d9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jul 24 20:38:22 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jul 24 20:41:26 2018 +0200

test: new lvcreate-raid1-error-read.sh

Test for MD RAID kernel bug in read_balance() preventing
reads of failed sectors to get rescheduled to another leg.
---
 test/shell/lvcreate-raid1-read-error.sh |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-raid1-read-error.sh b/test/shell/lvcreate-raid1-read-error.sh
new file mode 100644
index 0000000..6907758
--- /dev/null
+++ b/test/shell/lvcreate-raid1-read-error.sh
@@ -0,0 +1,31 @@
+#!/bin/sh
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# Test for MD raid1 kernel bug causing read
+# errors on failing first leg sectors.
+
+# Create VG with 2 PVs
+aux prepare_vg 2 2
+
+# Create 2-legged raid1 LV
+lvcreate --yes --type raid1 --mirrors 1 --extents 1 --name $lv $vg
+aux wait_for_sync $vg $lv
+
+aux error_dev "$dev1" 20:500
+
+dd if=$DM_DEV_DIR/$vg/$lv iflag=direct,fullblock of=/dev/zero bs=128K count=1
+
+vgremove --force $vg


