From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 16:31:16 +0000 (UTC)
Subject: master - tests: detect old-snap metadata consitency
Message-ID: <20140306163116.399B560DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0673b0ddc14c175a496770a77a90d08d035d71b
Commit:        d0673b0ddc14c175a496770a77a90d08d035d71b
Parent:        d5a00c459734e6db0f739764e853424379e8c767
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 4 23:47:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 17:30:10 2014 +0100

tests: detect old-snap metadata consitency

Add some test for correctness of snapshot metadata.
Based upon original test from Mikulas.
Needs correctly working kernel snapshot target.
---
 test/shell/snapshot-reactivate.sh |   55 +++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
new file mode 100644
index 0000000..289d81d
--- /dev/null
+++ b/test/shell/snapshot-reactivate.sh
@@ -0,0 +1,55 @@
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
+#
+# Checking consistency of old-snapshot metadata after de/activation
+# Validates recent snapshot target kernel updates and error
+# is triggered by kernel 3.14-rc[1..5]
+# http://www.redhat.com/archives/dm-devel/2014-March/msg00005.html
+#
+. lib/test
+
+# Snapshot should remain unmodified
+check_s_() {
+	md5sum -c md5
+	#diff data "$DM_DEV_DIR/$vg/s"
+}
+
+which md5sum || skip
+
+aux prepare_vg
+
+# 8M file with some random data
+dd if=/dev/urandom of=data bs=1M count=1
+dd if=data of=data bs=1M count=7 seek=1
+echo "$(md5sum data | cut -d' ' -f1) $DM_DEV_DIR/$vg/s" >md5
+
+lvcreate -L 8M -n o $vg
+dd if=data of="$DM_DEV_DIR/$vg/o" bs=1M
+
+lvcreate -L 8M -s -n s $vg/o
+check_s_
+
+dd if=data of="$DM_DEV_DIR/$vg/o" bs=1234567 count=1 skip=1
+check_s_
+lvchange -an $vg
+
+lvchange -ay $vg
+check_s_
+
+dd if=data of="$DM_DEV_DIR/$vg/o" bs=1234567 count=2 skip=1
+check_s_
+
+lvchange -an $vg
+lvchange -ay $vg
+check_s_
+
+vgremove -f $vg


