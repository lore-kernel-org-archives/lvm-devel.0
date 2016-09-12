From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Sep 2016 14:52:48 +0000 (UTC)
Subject: master - tests: move cache test to separate file
Message-ID: <20160912145248.C18C960F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4363fbcb57af5399ea9d503dd4ae21477c24d59
Commit:        a4363fbcb57af5399ea9d503dd4ae21477c24d59
Parent:        b592ea5bbcc9d348fdbacec1b4eeb9dded36d4ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 23:38:47 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 12 16:49:51 2016 +0200

tests: move cache test to separate file

Don't mix plain raid test with  'raid+cache' test.
---
 test/shell/lvchange-cache-syncaction-raid.sh |   43 ++++++++++++++++++++++++++
 test/shell/lvchange-syncaction-raid.sh       |   11 ------
 2 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvchange-cache-syncaction-raid.sh b/test/shell/lvchange-cache-syncaction-raid.sh
new file mode 100644
index 0000000..6a4546e
--- /dev/null
+++ b/test/shell/lvchange-cache-syncaction-raid.sh
@@ -0,0 +1,43 @@
+#!/bin/sh
+# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# test activation race for raid's --syncaction check
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+
+# Current support for syncaction in cluster is broken
+# might get fixed one day though
+# meanwhile skipped
+SKIP_WITH_CLVMD=1
+
+. lib/inittest
+
+aux have_cache 1 5 0 || skip
+
+# Proper mismatch count 1.5.2+ upstream, 1.3.5 < x < 1.4.0 in RHEL6
+aux have_raid 1 3 5 &&
+  ! aux have_raid 1 4 0 ||
+  aux have_raid 1 5 2 || skip
+aux prepare_vg 3
+
+
+# Bug 1169495 - RFE: allow raid scrubbing on cache origin raid volumes
+# lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
+#  then test that the origin can be scrubbed.
+lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
+lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
+lvconvert --cache -Zy --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvchange --syncaction check $vg/${lv1}_corig
+# Check may go too quickly to verify with check of syncaction
+
+vgremove -ff $vg
diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 448a688..7d7d3ed 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -88,15 +88,4 @@ aux wait_for_sync $vg $lv1
 # Retest mistmatch exists
 check lv_field $vg/$lv1 raid_mismatch_count "128"
 
-lvremove -ff $vg
-
-# Bug 1169495 - RFE: allow raid scrubbing on cache origin raid volumes
-# lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
-#  then test that the origin can be scrubbed.
-lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
-lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
-lvconvert --cache -Zy --cachepool $vg/${lv1}_cachepool $vg/$lv1
-lvchange --syncaction check $vg/${lv1}_corig
-# Check may go too quickly to verify with check of syncaction
-
 vgremove -ff $vg


