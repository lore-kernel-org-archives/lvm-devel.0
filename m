From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 13 Aug 2013 21:27:58 +0000 (UTC)
Subject: master - vgck: Fix #894136, notice on-disk corruption in spite of lvmetad.
Message-ID: <20130813212758.A132F60E35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0da72743ca46ae9f8185cd12d5c78b3c2b801872
Commit:        0da72743ca46ae9f8185cd12d5c78b3c2b801872
Parent:        1a1d3a10ffde42665b824a5c72bd526cb962ec1d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Aug 13 23:25:49 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Aug 13 23:25:49 2013 +0200

vgck: Fix #894136, notice on-disk corruption in spite of lvmetad.

---
 test/shell/vgck.sh |   31 +++++++++++++++++++++++++++++++
 tools/vgck.c       |    1 +
 2 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
new file mode 100644
index 0000000..772233c
--- /dev/null
+++ b/test/shell/vgck.sh
@@ -0,0 +1,31 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+aux prepare_vg 3
+lvcreate -n blabla -L 1 $vg
+
+dd if=/dev/urandom bs=512 seek=2 count=32 of=$dev2
+
+# TODO: aux lvmconf "global/locking_type = 4"
+
+if test -e LOCAL_LVMETAD; then
+    vgscan 2>&1 | tee vgscan.out
+    not grep "Inconsistent metadata found for VG $vg" vgscan.out
+else
+    not vgscan 2>&1 | tee vgscan.out
+    grep "Inconsistent metadata found for VG $vg" vgscan.out
+fi
+
+dd if=/dev/urandom bs=512 seek=2 count=32 of=$dev2
+vgck $vg 2>&1 | tee vgck.out
+grep Incorrect vgck.out
diff --git a/tools/vgck.c b/tools/vgck.c
index eb0ecaf..4ad045a 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -37,6 +37,7 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
+	lvmetad_set_active(0);
 	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       &vgck_single);
 }


