From: David Teigland <teigland@sourceware.org>
Date: Wed, 18 Sep 2019 14:30:40 -0400
Subject: stable-2.02 - tests: add test for pvscan activation of incomplete vg
Message-ID: <201909181830.x8IIUeSt021043@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44b98d77ecda701902c6c39b4c6ab7a09cfcce9b
Commit:        44b98d77ecda701902c6c39b4c6ab7a09cfcce9b
Parent:        1349b61bb72d3a42636053ede0d6fa71cd4f2d93
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 18 13:29:17 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 18 13:29:17 2019 -0500

tests: add test for pvscan activation of incomplete vg

---
 test/shell/lvmetad-pvscan-cache-init.sh |   58 +++++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache-init.sh b/test/shell/lvmetad-pvscan-cache-init.sh
new file mode 100644
index 0000000..69fecf3
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-cache-init.sh
@@ -0,0 +1,58 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+SKIP_WITHOUT_LVMETAD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 2
+
+pvcreate "$dev1"
+pvcreate "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -l1 -an -n $lv1 $vg1 "$dev1"
+lvcreate -l1 -an -n $lv2 $vg1 "$dev2"
+
+aux disable_dev "$dev2"
+
+kill "$(< LOCAL_LVMETAD)"
+for i in {200..0} ; do
+        test -e "$TESTDIR/lvmetad.socket" || break
+        test "$i" -eq 0 && die "Too slow closing of lvmetad.socket. Aborting test."
+        echo -n .; sleep .1;
+done # wait for the socket close
+test ! -e "$LVM_LVMETAD_PIDFILE"
+
+lvmetad
+
+while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket
+
+test -e "$LVM_LVMETAD_PIDFILE"
+
+cp "$LVM_LVMETAD_PIDFILE" LOCAL_LVMETAD
+
+pvscan --cache -aay "$dev1"
+
+check lv_field $vg1/$lv1 lv_active ""
+check lv_field $vg1/$lv2 lv_active ""
+
+aux enable_dev "$dev2"
+
+pvscan --cache -aay "$dev2"
+
+check lv_field $vg1/$lv1 lv_active "active"
+check lv_field $vg1/$lv2 lv_active "active"
+
+vgchange -an $vg1
+vgremove -ff $vg1


