From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:34 +0000 (UTC)
Subject: master - tests: lvconvert snapshot testing
Message-ID: <20140317133334.EC3CD606D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe8603dd609cb99f6a86b0345b6d0733aa1b5d1d
Commit:        fe8603dd609cb99f6a86b0345b6d0733aa1b5d1d
Parent:        27d556de9e895291f7c57b956cdb0036ff5d6e51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 13:15:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:45 2014 +0100

tests: lvconvert snapshot testing

---
 test/shell/lvconvert-snapshot.sh |   57 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
new file mode 100644
index 0000000..4a650d2
--- /dev/null
+++ b/test/shell/lvconvert-snapshot.sh
@@ -0,0 +1,57 @@
+#!/bin/sh
+
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
+# Test various supported conversion of snapshot
+
+. lib/test
+
+aux prepare_pvs 1
+
+vgcreate -s 1k $vg $(cat DEVICES)
+
+lvcreate -V50 -L1 -n $lv1 -s $vg
+
+lvcreate -L1 -n $lv2 $vg
+lvcreate -L1 -s -n $lv3 $vg/$lv2
+
+lvcreate -l1 -n $lv4 $vg
+lvcreate -L1 -n $lv5 $vg
+
+not lvconvert -s $vg/$lv1 $vg/not_exist
+
+# Can't convert to snapshot of origin
+not lvconvert -s $vg/$lv1 $vg/$lv2
+not lvconvert -s $vg/$lv2 $vg/$lv1
+not lvconvert -s $vg/$lv5 $vg/$lv1
+
+not lvconvert -s $vg/$lv5 $vg/$lv2
+not lvconvert -s $vg/$lv5 $vg/$lv3
+
+# Can't be itself
+not lvconvert -s $vg/$lv1 $vg/$lv1
+not lvconvert -s $vg/$lv2 $vg/$lv2
+
+# Can't convert snapshot to snapshot
+not lvconvert -s $vg/$lv1 $vg/$lv3
+not lvconvert -s $vg/$lv2 $vg/$lv3
+
+# Can't make a real LV snapshot of virtual 'zero' snapshot
+not lvconvert -s $vg/$lv1 $vg/$lv4
+
+# Check minimum size
+not lvconvert -s $vg/$lv2 $vg/$lv4 2>&1 | tee err
+grep "smaller" err
+
+# This should pass
+lvconvert -s $vg/$lv2 $vg/$lv5
+
+vgremove -f $vg


