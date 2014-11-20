From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:15 +0000 (UTC)
Subject: master - test: Add a test for lvchange --cachepolicy.
Message-ID: <20141120155315.8CC0760E33@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=310beb73a8a2d3a6ed7a28a3346306be82bbc533
Commit:        310beb73a8a2d3a6ed7a28a3346306be82bbc533
Parent:        c164f59631ca08f56c5f1e2e6cf677f3a85145fb
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 18:49:15 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:07 2014 +0100

test: Add a test for lvchange --cachepolicy.

---
 test/shell/lvchange-cache.sh |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
new file mode 100644
index 0000000..e790cbb
--- /dev/null
+++ b/test/shell/lvchange-cache.sh
@@ -0,0 +1,35 @@
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
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+aux prepare_vg 3
+
+lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
+lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
+lvcreate -n noncache -l 1 $vg
+
+not lvchange --cachepolicy policy=mq $vg/noncache
+
+lvchange --cachepolicy policy=mq --cachepolicy migration_threshold=333 $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
+lvchange --refresh $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
+lvchange -an $vg
+lvchange -ay $vg
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
+
+lvchange --cachepolicy 'migration_threshold = 233 sequential_threshold = 13' $vg/corigin
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+
+vgremove -f $vg


