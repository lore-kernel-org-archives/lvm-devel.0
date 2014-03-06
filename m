From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  6 Mar 2014 16:31:18 +0000 (UTC)
Subject: master - tests: check created snapshot has good max size
Message-ID: <20140306163118.5195A60DF1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b561a7a3b0a9dde9bba139154ebc881e89542e5
Commit:        6b561a7a3b0a9dde9bba139154ebc881e89542e5
Parent:        d0673b0ddc14c175a496770a77a90d08d035d71b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 6 17:19:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 6 17:30:10 2014 +0100

tests: check created snapshot has good max size

Testing if we are creating large enough old-snapshot
(so the COW max size is correct)
https://bugzilla.redhat.com/show_bug.cgi?id=1035871
---
 test/shell/snapshot-maxsize.sh |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
new file mode 100644
index 0000000..3d49a61
--- /dev/null
+++ b/test/shell/snapshot-maxsize.sh
@@ -0,0 +1,31 @@
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
+# Testing calculation of snapshot space
+# https://bugzilla.redhat.com/show_bug.cgi?id=1035871
+
+. lib/test
+
+aux prepare_pvs 1
+
+vgcreate -s 1K $vg $(cat DEVICES)
+
+lvcreate -L1 -n $lv1 $vg
+# Snapshot should be large enough to handle any writes
+lvcreate -L2 -s $vg/$lv1 -n $lv2
+
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1
+
+get lv_field $vg/$lv2 lv_attr | tee attrs
+# Snapshot must not be invalid here
+grep -v "....I" attrs
+
+vgremove -f $vg


