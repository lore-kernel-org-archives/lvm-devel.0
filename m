From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Sep 2014 20:05:48 +0000 (UTC)
Subject: master - tests: test for rename of snapshot
Message-ID: <20140910200548.546816055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d936d56e02d59aaae7ee52b2a3c5a1a18e5510e
Commit:        4d936d56e02d59aaae7ee52b2a3c5a1a18e5510e
Parent:        3a5eb1bc38b8555d7ae0d16fa07db96a3b73db16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 10 22:02:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 10 22:02:18 2014 +0200

tests: test for rename of snapshot

---
 test/shell/snapshot-rename.sh |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-rename.sh b/test/shell/snapshot-rename.sh
new file mode 100644
index 0000000..8d1eefb
--- /dev/null
+++ b/test/shell/snapshot-rename.sh
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
+# Testing renaming snapshots (had problem in cluster)
+# https://bugzilla.redhat.com/show_bug.cgi?id=1136925
+
+. lib/inittest
+
+aux prepare_vg 1
+
+lvcreate -aey -L1 -n $lv1 $vg
+lvcreate -s -L1 -n $lv2 $vg/$lv1
+lvrename $vg/$lv2 $vg/$lv3
+lvremove -f $vg/$lv1
+
+vgremove -f $vg


