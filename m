From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:37 +0000 (UTC)
Subject: master - tests: zero and error type tests
Message-ID: <20140317133337.10290606D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e398901ed1d77684155a52c464f6265f68a96562
Commit:        e398901ed1d77684155a52c464f6265f68a96562
Parent:        fe8603dd609cb99f6a86b0345b6d0733aa1b5d1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 13:16:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:45 2014 +0100

tests: zero and error type tests

---
 test/shell/error-usage.sh |   33 +++++++++++++++++++++++++++++++++
 test/shell/zero-usage.sh  |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
new file mode 100644
index 0000000..a7e3593
--- /dev/null
+++ b/test/shell/error-usage.sh
@@ -0,0 +1,33 @@
+#!/bin/bash
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
+# Basic usage of zero target
+
+. lib/test
+
+which md5sum || skip
+
+aux prepare_pvs 1
+
+vgcreate -s 256k $vg $(cat DEVICES)
+
+lvcreate --type error -L1 -n $lv1 $vg
+lvextend -L+1 $vg/$lv1
+
+# has to match
+
+check lv_field $vg/$lv1 lv_modules "error"
+check lv_field $vg/$lv1 segtype "error"
+check lv_field $vg/$lv1 seg_count "1"
+check lv_field $vg/$lv1 seg_size_pe "8"   # 8 * 256
+
+# FIXME should we print info we are ignoring stripping?
+lvextend -L+1 -I64 -i2 $vg/$lv1
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
new file mode 100644
index 0000000..b140558
--- /dev/null
+++ b/test/shell/zero-usage.sh
@@ -0,0 +1,34 @@
+#!/bin/bash
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
+# Basic usage of zero target
+
+. lib/test
+
+which md5sum || skip
+
+aux prepare_pvs 1
+
+vgcreate -s 256k $vg $(cat DEVICES)
+
+lvcreate --type zero -L1 -n $lv1 $vg
+lvextend -L+1 $vg/$lv1
+
+sum1=$(dd if=/dev/zero bs=2M count=1 | md5sum | cut -f1 -d' ')
+sum2=$(dd if="$DM_DEV_DIR/$vg/$lv1" bs=2M count=1 | md5sum | cut -f1 -d' ')
+
+# has to match
+test "$sum1" = "$sum2"
+
+check lv_field $vg/$lv1 lv_modules "zero"
+check lv_field $vg/$lv1 segtype "zero"
+check lv_field $vg/$lv1 seg_count "1"
+check lv_field $vg/$lv1 seg_size_pe "8"   # 8 * 256


