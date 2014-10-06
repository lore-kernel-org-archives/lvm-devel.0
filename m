From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:34:07 +0000 (UTC)
Subject: master - tests: lvconvert cache usage of thin pool
Message-ID: <20141006133407.1F34860905@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa517221a19751b93a5b94f8b379919b9c1c0226
Commit:        fa517221a19751b93a5b94f8b379919b9c1c0226
Parent:        742d250cc52dcbd965310b1bf5357d4793254f4d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 15:30:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:31:44 2014 +0200

tests: lvconvert cache usage of thin pool

Checked stacking usage of thin pool data volume being cached.
---
 test/shell/lvconvert-cache-thin.sh |   50 ++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
new file mode 100644
index 0000000..87256a4
--- /dev/null
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -0,0 +1,50 @@
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
+# Exercise usage of stacked cache volume used in thin pool volumes
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+aux have_thin 1 0 0 || skip
+
+aux prepare_vg 5 80
+
+lvcreate -L10 -n cpool $vg
+lvcreate -L10 -n tpool $vg
+lvcreate -L10 -n $lv1 $vg
+
+lvconvert --yes --cache --cachepool cpool $vg/tpool
+
+# Currently the only allowed stacking is cache thin data volume
+lvconvert --yes --type thin-pool $vg/tpool
+
+lvcreate -V10 -T -n $lv2 $vg/tpool
+
+aux mkdev_md5sum $vg $lv2
+
+lvconvert --splitcache $vg/tpool
+
+check dev_md5sum $vg $lv2
+lvchange -an $vg
+lvchange -ay $vg
+check dev_md5sum $vg $lv2
+
+lvs -a $vg
+lvconvert --yes --cache --cachepool cpool $vg/tpool
+
+lvconvert --yes -T --thinpool $vg/tpool $vg/$lv1
+check lv_field $vg/tpool segtype "thin-pool"
+check lv_field $vg/$lv1 segtype "thin"
+lvconvert --uncache $vg/tpool
+lvs -a $vg
+
+vgremove -f $vg


