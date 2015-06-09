From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  9 Jun 2015 19:01:22 +0000 (UTC)
Subject: master - raid0 commit missed test/shell/lvconvert-striped-raid0.sh
Message-ID: <20150609190122.1B68460B3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5c64f4b9bb748c46d7e3c052f1524eee4bb845e
Commit:        d5c64f4b9bb748c46d7e3c052f1524eee4bb845e
Parent:        c2c0a029fe5fcb8585039073ca49c023d237a300
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Jun 9 21:00:56 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Jun 9 21:00:56 2015 +0200

raid0 commit missed test/shell/lvconvert-striped-raid0.sh

---
 test/shell/lvconvert-striped-raid0.sh |   73 +++++++++++++++++++++++++++++++++
 1 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-striped-raid0.sh b/test/shell/lvconvert-striped-raid0.sh
new file mode 100644
index 0000000..fb7c5a1
--- /dev/null
+++ b/test/shell/lvconvert-striped-raid0.sh
@@ -0,0 +1,73 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+########################################################
+# MAIN
+########################################################
+aux have_raid 1 3 0 || skip
+
+aux prepare_pvs 6 20  # 6 devices for striped test
+vgcreate -s 128k $vg $(cat DEVICES)
+
+############################################
+# Create striped LV, convert to raid0* tests
+############################################
+# Create striped 6-way and cycle conversions
+lvcreate -y -i 6 -l 50%FREE -n $lv1 $vg
+lvconvert --type raid0 $vg/$lv1
+lvconvert --type raid0_meta $vg/$lv1
+lvconvert --type striped $vg/$lv1
+lvremove -ff $vg
+
+# Create raid0 5-way and cycle conversions
+lvcreate -y --type raid0 -i 5 -l 50%FREE -n $lv1 $vg
+lvconvert --type raid0_meta $vg/$lv1
+lvconvert --type striped $vg/$lv1
+lvconvert --type raid0 $vg/$lv1
+lvremove -ff $vg
+
+# Create raid0_meta 4-way and cycle conversions
+lvcreate -y --type raid0_meta -i 4 -l 50%FREE -n $lv1 $vg
+lvconvert --type raid0 $vg/$lv1
+lvconvert --type striped $vg/$lv1
+lvconvert --type raid0_meta $vg/$lv1
+lvremove -ff $vg
+
+# Create striped 3-way cosuming all vg space
+lvcreate -y -i 3 -l 100%FREE -n $lv1 $vg
+lvconvert --type raid0 $vg/$lv1
+not lvconvert --type raid0_meta $vg/$lv1
+lvconvert --type striped $vg/$lv1
+lvremove -ff $vg
+
+# Not enough drives
+not lvcreate -y -i3 -l1 $vg "$dev1" "$dev2"
+not lvcreate -y --type raid0 -i3 -l1 $vg "$dev1" "$dev2"
+not lvcreate -y --type raid0_meta -i4 -l1 $vg "$dev1" "$dev2" "$dev3"
+
+# Create 2..6-way raid0 LV and cycle conversions
+for s in $(seq 2..6)
+do
+	lvcreate -y --type raid0 -l 95%FREE -i $s -n $lv1 $vg
+	lvconvert --type raid0_meta $vg/$lv1
+	lvconvert --type raid0 $vg/$lv1
+	lvconvert --type striped $vg/$lv1
+	lvconvert --type raid0 $vg/$lv1
+	lvconvert --type raid0_meta $vg/$lv1
+	lvremove -ff $vg
+done
+
+# Not enough drives for 7-way
+not lvcreate -y --type raid0 -l 7 -i 7 -n $lv1 $vg
+
+vgremove -ff $vg


