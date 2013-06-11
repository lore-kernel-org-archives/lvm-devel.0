From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:09:16 +0000 (UTC)
Subject: master - tests: lvresize thin
Message-ID: <20130611120916.CBBCE613C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ac0f58ea13dc068806ff1085e0ea06a7840d5fd
Commit:        9ac0f58ea13dc068806ff1085e0ea06a7840d5fd
Parent:        4937df4aed699a5e3bc3c860e897fa0e448cfc6b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 13:35:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 14:07:51 2013 +0200

tests: lvresize thin

---
 test/shell/lvresize-thin-metadata.sh |   35 ++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvresize-thin-metadata.sh b/test/shell/lvresize-thin-metadata.sh
new file mode 100644
index 0000000..10dbb4a
--- /dev/null
+++ b/test/shell/lvresize-thin-metadata.sh
@@ -0,0 +1,35 @@
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
+aux have_thin 1 8 0 || skip
+
+aux prepare_pvs 3
+
+vgcreate -s 1M $vg $(cat DEVICES)
+
+lvcreate -l1 -T $vg/pool
+
+# Confirm we have basic 2M metadata
+check lv_field $vg/pool_tmeta size "2.00m"
+
+lvresize --poolmetadata +2 $vg/pool
+
+# Test it's been resized to 4M
+check lv_field $vg/pool_tmeta size "4.00m"
+
+# TODO: Add more tests when kernel is fixed
+
+
+# TODO: Make a full metadata device and test dmeventd support
+
+vgremove -ff $vg


