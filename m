From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 10 Sep 2014 22:02:16 +0000 (UTC)
Subject: master - tests: test for rename of snapshot
Message-ID: <20140910220216.DFE6160515@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55aa3cc813620ecbf2f569720fb24107e737b836
Commit:        55aa3cc813620ecbf2f569720fb24107e737b836
Parent:        a86d9a3b305be466d221f2a5e210bc1cad8fe842
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 9 20:17:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 9 20:17:47 2014 +0200

tests: test for rename of snapshot

---
 test/shell/snapshot-cluster.sh |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-cluster.sh b/test/shell/snapshot-cluster.sh
new file mode 100644
index 0000000..051c165
--- /dev/null
+++ b/test/shell/snapshot-cluster.sh
@@ -0,0 +1,24 @@
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
+# Testing renaming snapshots in cluster
+# https://bugzilla.redhat.com/show_bug.cgi?id=1136925
+
+. lib/inittest
+
+aux prepare_vg 1
+
+lvcreate -aey -L1 -n $lv1 $vg
+lvcreate -s -L1 -n $lv2 $vg/$lv1
+lvrename  $vg/$lv2 $vg/$lv3
+lvremove -f $vg/$lv1
+
+vgremove -f $vg


