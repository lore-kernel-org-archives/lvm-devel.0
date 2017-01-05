From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jan 2017 14:56:44 +0000 (UTC)
Subject: master - tests: drop FIXME
Message-ID: <20170105145644.1892E60E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c64f4447d92c4c8bc72d33a9615ef62fcef41168
Commit:        c64f4447d92c4c8bc72d33a9615ef62fcef41168
Parent:        74969c9a38c286037d499a6ed603b1ae806cd37b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 4 11:21:20 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 5 15:54:14 2017 +0100

tests: drop FIXME

Since we fixed core trouble with sequence of
suspend/resume/suspend without udev wait
we can drop 'should' and expect volume is still mounted.
---
 test/shell/lvconvert-thin-external-cache.sh |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-thin-external-cache.sh b/test/shell/lvconvert-thin-external-cache.sh
index dae65a0..c4d7d61 100644
--- a/test/shell/lvconvert-thin-external-cache.sh
+++ b/test/shell/lvconvert-thin-external-cache.sh
@@ -50,11 +50,8 @@ not lvconvert --thin --thinpool $vg/tpool $vg/$lv1
 # Switch to 'writethrough' - this should be supported
 lvchange --cachemode writethrough $vg/$lv1
 
-# FIXME
-# systemd on fc23 'strikes-in' and unmounts  mnt
-# ATM the reason is unclear (bug in systemd, bad udev rules?)
-#   as a workaround mount again and 'WARN' test
-should not mount "$DM_DEV_DIR/$vg/$lv1" mnt
+# Check $lv1 remains mounted (so it's not been unmounted by systemd)
+not mount "$DM_DEV_DIR/$vg/$lv1" mnt
 
 lvconvert --thin $vg/$lv1 --originname extorg --thinpool $vg/tpool
 


