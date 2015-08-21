From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Aug 2015 13:36:22 +0000 (UTC)
Subject: master - tests: check cachepolicy with lvconvert
Message-ID: <20150821133622.0ED156115A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c811bfcd96abcd5058a6dc9877502072a862833
Commit:        1c811bfcd96abcd5058a6dc9877502072a862833
Parent:        6d9e7d48fb34010f0e1447e99a92193b153acdc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 21 15:34:32 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 21 15:35:45 2015 +0200

tests: check cachepolicy with lvconvert

---
 test/shell/lvconvert-cache-smq.sh |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-smq.sh b/test/shell/lvconvert-cache-smq.sh
new file mode 100644
index 0000000..cdc7838
--- /dev/null
+++ b/test/shell/lvconvert-cache-smq.sh
@@ -0,0 +1,32 @@
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
+# Exercise conversion of cache and cache pool
+
+. lib/inittest
+
+test -e LOCAL_LVMPOLLD && skip
+
+aux have_cache 1 8 0 || skip
+
+aux prepare_vg 5 80
+
+lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
+
+lvcreate -H --cachepolicy smq -L 4 -n corigin --cachepool $vg/cpool
+
+check lv_field $vg/corigin cache_policy "smq"
+
+lvconvert --splitcache $vg/corigin
+
+lvs -o+cache_policy -a $vg
+
+vgremove -f $vg


