From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:37 +0200
Subject: [PATCH 25/25] Replicator: initial simple replicator testcase
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <efed66a56d9dfda737fc776e7dd661cfc75fd6c1.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-replicator-usage.sh |   47 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)
 create mode 100755 test/t-replicator-usage.sh

diff --git a/test/t-replicator-usage.sh b/test/t-replicator-usage.sh
new file mode 100755
index 0000000..7abcc4f
--- /dev/null
+++ b/test/t-replicator-usage.sh
@@ -0,0 +1,47 @@
+#!/bin/sh
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some vgcreate diagnostics'
+
+. ./test-utils.sh
+
+aux prepare_pvs 3
+
+vgl=${PREFIX}vgl
+vgn=${PREFIX}vgn
+vgp=${PREFIX}vgp
+rep=${vgl}/rep
+
+#COMM create 3 VGs'
+vgcreate -c n $vgl $dev1
+vgcreate -c n $vgn $dev2
+vgcreate -c n $vgp $dev3
+
+#COMM remote site N
+lvcreate -l1 -n $lv1 $vgn
+lvcreate -l2 -n $lv2 $vgn
+
+#COMM remote site P
+lvcreate -l1 -n $lv1 $vgp
+lvcreate -l2 -n $lv2 $vgp
+
+lvcreate --replicator -l1 -n rep $vgl
+
+lvcreate --site Berlin --replicator $rep
+
+lvcreate --site NY --remotevg $vgn --replicator $rep
+lvcreate --site Paris --remotevg $vgp --replicator $rep
+
+lvcreate --replicated -l1 -n $lv1 $rep
+lvcreate --replicated -l2 -n $lv2 $rep
+
+# active site Berlin - using any replicated LV
+lvchange -ay --site Berlin $vgl/$lv1
-- 
1.7.2.1


