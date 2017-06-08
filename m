From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Jun 2017 06:03:45 -0400
Subject: master - tests: check thin-pool boundary sizes
Message-ID: <201706081003.v58A3juZ007799@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee5ecde35eca656e85ee5c83b15ad4029d0acf4d
Commit:        ee5ecde35eca656e85ee5c83b15ad4029d0acf4d
Parent:        48ffb996c5218472996b1b6d557fa51de0f6e9b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 8 11:45:14 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 8 11:58:36 2017 +0200

tests: check thin-pool boundary sizes

---
 test/shell/thin-large.sh |   54 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-large.sh b/test/shell/thin-large.sh
new file mode 100644
index 0000000..da5a7ec
--- /dev/null
+++ b/test/shell/thin-large.sh
@@ -0,0 +1,54 @@
+#!/bin/sh
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# 'Exercise logic around boundary sizes of thin-pool data and chunksize
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# FIXME  update test to make something useful on <16T
+aux can_use_16T || skip
+
+aux have_thin 1 0 0 || skip
+
+# Prepare ~1P sized devices
+aux prepare_vg 1 1000000000
+
+lvcreate -an -T -L250T $vg/pool250
+
+lvcreate -an -T -L250T --poolmetadatasize 16G $vg/pool16
+
+fail lvcreate -an -T -L250T --chunksize 64K --poolmetadatasize 16G $vg/pool64
+
+# Creation of thin-pool with proper chunk-size but not enough metadata size
+# which can grow later needs to pass
+lvcreate -an -T -L250T --chunksize 1M --poolmetadatasize 4G $vg/pool1024
+
+# Creation of chunk should fit
+lvcreate -an -T -L12T --chunksize 64K --poolmetadatasize 16G $vg/pool64
+
+check lv_field $vg/pool64 chunksize "64.00k"
+
+lvremove -ff $vg
+
+
+### Check also lvconvert ###
+
+lvcreate -an -L250T -n pool $vg
+
+fail lvconvert -y --chunksize 64 --thinpool $vg/pool
+lvconvert -y --chunksize 1M --thinpool $vg/pool
+
+check lv_field $vg/pool chunksize "1.00m"
+
+vgremove -ff $vg


