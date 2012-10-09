From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 08:25:17 +0000 (UTC)
Subject: master - TEST: Check that LVM1 VGs work when using lvmetad (BZ 863401).
Message-ID: <20121009082517.631A6121A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ff2f1a3dbaa6f77b1693b7a9cf540a902cf618d
Commit:        9ff2f1a3dbaa6f77b1693b7a9cf540a902cf618d
Parent:        06243be91b12a7bb249d2b18cf5eeb0492ccfa4f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 9 07:59:53 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 9 07:59:53 2012 +0200

TEST: Check that LVM1 VGs work when using lvmetad (BZ 863401).

---
 test/shell/lvmetad-lvm1.sh |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
new file mode 100644
index 0000000..c183fec
--- /dev/null
+++ b/test/shell/lvmetad-lvm1.sh
@@ -0,0 +1,21 @@
+#!/bin/sh
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+test -e LOCAL_LVMETAD || skip
+aux prepare_devs 2
+pvcreate --metadatatype 1 $dev1
+vgscan --cache
+pvs | grep $dev1
+vgcreate --metadatatype 1 $vg1 $dev1
+vgs | grep $vg1
+pvs | grep $dev1


