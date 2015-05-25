From: okozina <okozina@fedoraproject.org>
Date: Mon, 25 May 2015 08:49:26 +0000 (UTC)
Subject: master - tests: add test for pvscan --cache --background
Message-ID: <20150525084926.6FF8961026@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da20e0c5079eab7d76e3bae96ed3f4dd473efde6
Commit:        da20e0c5079eab7d76e3bae96ed3f4dd473efde6
Parent:        f8bf6410954fcf82bf28852e0dba015c6b7f19dc
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 25 10:41:14 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 25 10:48:45 2015 +0200

tests: add test for pvscan --cache --background

regression test for a segfault in pvscan --cache --background
bug fixed by commit:
f8bf6410954fcf82bf28852e0dba015c6b7f19dc
---
 test/shell/lvmetad-pvscan-nomda-bg.sh |   57 +++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-nomda-bg.sh b/test/shell/lvmetad-pvscan-nomda-bg.sh
new file mode 100644
index 0000000..e17dfd2
--- /dev/null
+++ b/test/shell/lvmetad-pvscan-nomda-bg.sh
@@ -0,0 +1,57 @@
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
+test -e LOCAL_LVMETAD || skip
+test -e LOCAL_LVMPOLLD && skip
+
+kill $(< LOCAL_LVMETAD)
+rm LOCAL_LVMETAD
+
+aux prepare_devs 2
+
+pvcreate --metadatacopies 0 "$dev1"
+pvcreate --metadatacopies 1 "$dev2"
+vgcreate $vg1 "$dev1" "$dev2"
+lvcreate -n foo -l 1 -an --zero n $vg1
+
+# start lvmetad but make sure it doesn't know about $dev1 or $dev2
+aux disable_dev "$dev1" "$dev2"
+aux prepare_lvmetad
+lvs
+mv LOCAL_LVMETAD XXX
+aux enable_dev "$dev2" "$dev1"
+mv XXX LOCAL_LVMETAD
+
+aux lvmconf 'global/use_lvmetad = 0'
+check inactive $vg1 foo
+aux lvmconf 'global/use_lvmetad = 1'
+
+pvscan --cache --background "$dev2" -aay
+
+aux lvmconf 'global/use_lvmetad = 0'
+# FIXME: inconclusive. may be a timing issue
+check inactive $vg1 foo
+aux lvmconf 'global/use_lvmetad = 1'
+
+pvscan --cache --background "$dev1" -aay
+
+aux lvmconf 'global/use_lvmetad = 0'
+i=100
+while ! check active $vg1 foo; do
+	test $i -lt 0 && fail "Failed to autoactivate"
+	sleep .1
+	i=$((i-1))
+done
+aux lvmconf 'global/use_lvmetad = 1'
+
+vgremove -ff $vg1


