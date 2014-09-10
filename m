From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 10 Sep 2014 22:02:25 +0000 (UTC)
Subject: master - test: Add a test for MD component detection in pvscan --cache.
Message-ID: <20140910220225.5A089610FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f9b30d17807aeb3bd31a3490cf9a45223324a4f
Commit:        5f9b30d17807aeb3bd31a3490cf9a45223324a4f
Parent:        a7be3b12dfe7388d1648595e6cc4c7a1379bb8a7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 9 17:25:29 2014 +0200
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 10 22:58:12 2014 +0100

test: Add a test for MD component detection in pvscan --cache.

---
 test/shell/lvmetad-pvscan-md.sh |   77 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 77 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
new file mode 100644
index 0000000..dd85bb6
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -0,0 +1,77 @@
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
+. lib/inittest
+
+test -e LOCAL_LVMETAD || skip
+which mdadm || skip
+
+test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
+	modprobe raid0 || skip
+
+aux lvmconf 'devices/md_component_detection = 1'
+aux extend_filter_LVMTEST
+aux extend_filter "a|/dev/md.*|"
+
+aux prepare_devs 2
+
+# TODO factor out the following MD-creation code into lib/
+
+# Have MD use a non-standard name to avoid colliding with an existing MD device
+# - mdadm >= 3.0 requires that non-standard device names be in /dev/md/
+# - newer mdadm _completely_ defers to udev to create the associated device node
+mdadm_maj=$(mdadm --version 2>&1 | perl -pi -e 's|.* v(\d+).*|\1|')
+[ $mdadm_maj -ge 3 ] && \
+    mddev=/dev/md/md_lvm_test0 || \
+    mddev=/dev/md_lvm_test0
+
+cleanup_md() {
+    # sleeps offer hack to defeat: 'md: md127 still in use'
+    # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
+    aux udev_wait
+    mdadm --stop "$mddev" || true
+    aux udev_wait
+    if [ -b "$mddev" ]; then
+        # mdadm doesn't always cleanup the device node
+	sleep 2
+	rm -f "$mddev"
+    fi
+}
+
+cleanup_md_and_teardown() {
+    cleanup_md
+    aux teardown
+}
+
+# create 2 disk MD raid0 array (stripe_width=128K)
+test -b "$mddev" && skip
+mdadm --create --metadata=1.0 "$mddev" --auto=md --level 0 --raid-devices=2 --chunk 64 "$dev1" "$dev2"
+trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
+test -b "$mddev" || skip
+cp -LR "$mddev" "$DM_DEV_DIR" # so that LVM/DM can see the device
+lvmdev="$DM_DEV_DIR/md_lvm_test0"
+
+# TODO end MD-creation code
+
+# maj=$(($(stat -L --printf=0x%t "$dev2")))
+# min=$(($(stat -L --printf=0x%T "$dev2")))
+
+pvcreate $lvmdev
+
+pvscan --cache "$lvmdev"
+
+# ensure that lvmetad can only see the toplevel MD device
+not pvscan --cache "$dev1" 2>&1 | grep "not found"
+not pvscan --cache "$dev2" 2>&1 | grep "not found"
+
+pvs | grep $lvmdev
+pvs | not grep $dev1
+pvs | not grep $dev2


