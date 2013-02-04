From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:06 +0000 (UTC)
Subject: master - test: regression test for lvmetad error
Message-ID: <20130204180806.84E403523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1becaefe5792a3cd9484e76bb8738f6082a1249
Commit:        c1becaefe5792a3cd9484e76bb8738f6082a1249
Parent:        8ed0b6f312e0e9b5566934c5d30f79c1450fba2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 7 10:57:59 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:10 2013 +0100

test: regression test for lvmetad error

---
 test/shell/snapshot-lvm1.sh |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
new file mode 100644
index 0000000..cb55ed6
--- /dev/null
+++ b/test/shell/snapshot-lvm1.sh
@@ -0,0 +1,28 @@
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
+# regression test for lvmetad reporting error:
+# Internal error: LV snap_with_lvm1_meta (00000000000000000000000000000001) missing from preload metadata
+
+. lib/test
+
+aux prepare_devs 2
+
+vgcreate --metadatatype 1 $vg $(cat DEVICES)
+
+# Make origin volume
+lvcreate -l5 $vg -n origin
+
+# Create a snap of origin
+lvcreate -s $vg/origin -n snap_with_lvm1_meta -l4
+
+# Remove volume snapper/snap_with_lvm1_meta
+lvremove -f $vg/snap_with_lvm1_meta


