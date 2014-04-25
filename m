From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 25 Apr 2014 21:59:42 +0000 (UTC)
Subject: master - test: Add the new vgsplit RAID test file forgotten in the last commit
Message-ID: <20140425215942.02DBB60F45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bce3ad52a6c1fafd55573c465486faed3bb0a77
Commit:        3bce3ad52a6c1fafd55573c465486faed3bb0a77
Parent:        c671be434c15bf10b624ba8aaa43a378833179d5
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 25 16:59:09 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 25 16:59:09 2014 -0500

test: Add the new vgsplit RAID test file forgotten in the last commit

---
 test/shell/vgsplit-raid.sh |   58 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
new file mode 100644
index 0000000..898fc9a
--- /dev/null
+++ b/test/shell/vgsplit-raid.sh
@@ -0,0 +1,58 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test vgsplit operation, including different LV types
+
+. lib/test
+
+COMM() {
+	LAST_TEST="$@"
+}
+
+create_vg_() {
+	vgcreate -s 64k "$@"
+}
+
+aux target_at_least dm-raid 1 1 0 || skip
+
+aux prepare_pvs 5 10
+
+#
+# vgsplit can be done into a new or existing VG
+#
+for i in new existing
+do
+	#
+	# We can have PVs or LVs on the cmdline
+	#
+	for j in PV LV
+	do
+COMM "vgsplit correctly splits RAID LV into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
+		test $i = existing && create_vg_ $vg2 "$dev5"
+
+		lvcreate -an -Zn -l 64 --type raid5 -i 2 -n $lv1 $vg1
+		if [ $j = PV ]; then
+		  not vgsplit $vg1 $vg2 "$dev1"
+		  not vgsplit $vg1 $vg2 "$dev2"
+		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 4 1 0
+		else
+		  check pvlv_counts $vg2 3 1 0
+		fi
+		vgremove -f $vg2
+	done
+done


