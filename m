From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Feb 2014 10:17:58 +0000 (UTC)
Subject: master - tests: support for older snapshot target version
Message-ID: <20140226101758.E0D4C60FE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5e03c88b8b31db9a4b27c2e1a50441f99e0da48
Commit:        b5e03c88b8b31db9a4b27c2e1a50441f99e0da48
Parent:        aef60160112832b2773b128e30668d4fe3dda707
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 26 11:16:08 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 26 11:17:39 2014 +0100

tests: support for older snapshot target version

TODO: unsure about 1.10...
---
 test/shell/snapshot-usage.sh |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index bf78ac5..4d15fb1 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -135,8 +135,12 @@ lvcreate -s -pr -l12 -n snap $vg1/$lv
 #dd if="$DM_DEV_DIR/$vg1/snap" of=/dev/null bs=1M count=2
 fsck -n "$DM_DEV_DIR/$vg1/snap"
 
-# This would trigger read of weird percentage for undeleted header
-check lv_field $vg1/snap data_percent "0.00"
+# This test would trigger read of weird percentage for undeleted header
+# And since older snapshot target counts with metadata sectors
+# we have 2 valid results  (unsure about correct version number)
+EXPECT="0.00"
+aux target_at_least dm-snapshot 1 10 0 || EXPECT="66.67"
+check lv_field $vg1/snap data_percent "$EXPECT"
 
 vgremove -ff $vg1
 


