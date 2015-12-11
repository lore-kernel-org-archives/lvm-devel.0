From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Dec 2015 19:17:19 +0000 (UTC)
Subject: master - tests: check lvrename of stacked cache pool
Message-ID: <20151211191719.35CCB6032D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07b9147ced413d20ccedc6065fc3ca7382a4889f
Commit:        07b9147ced413d20ccedc6065fc3ca7382a4889f
Parent:        7a4badc07fbb864be3014c14e61e8c606593437d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 11 20:11:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 11 20:15:57 2015 +0100

tests: check lvrename of stacked cache pool

---
 test/shell/lvrename-cache-thin.sh |   48 +++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvrename-cache-thin.sh b/test/shell/lvrename-cache-thin.sh
new file mode 100644
index 0000000..434b08b
--- /dev/null
+++ b/test/shell/lvrename-cache-thin.sh
@@ -0,0 +1,48 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check rename of stacked  thin over cached LV
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 1 80
+
+lvcreate -L10 -n cpool $vg
+lvcreate -L10 -n tpool $vg
+lvcreate -L10 -n $lv1 $vg
+
+lvconvert --yes --cache --cachepool cpool $vg/tpool
+
+# currently the only allowed stacking is cache thin data volume
+lvconvert --yes --type thin-pool $vg/tpool
+
+lvcreate -V10 $vg/tpool
+
+# check cache pool remains same after thin-pool rename
+lvrename $vg/tpool  $vg/newpool
+
+check lv_exists $vg newpool cpool
+check lv_not_exists $vg tpool
+
+# allowing rename of internal cache pool
+lvrename $vg/cpool  $vg/cachepool
+
+check lv_exists $vg cachepool
+check lv_not_exists $vg cpool
+
+lvs -a $vg
+
+vgremove -f $vg


