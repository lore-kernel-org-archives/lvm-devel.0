From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:32 +0000 (UTC)
Subject: master - tests: workaround failure on fc23
Message-ID: <20161222223832.3E2C1611D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1053d46aff11a8e592ca91ba56d6400f4693b9a5
Commit:        1053d46aff11a8e592ca91ba56d6400f4693b9a5
Parent:        dd19b5698553b4eb0214825a6dcb88a5330b4097
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 16:29:23 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

tests: workaround failure on fc23

---
 test/shell/lvconvert-thin-external-cache.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin-external-cache.sh b/test/shell/lvconvert-thin-external-cache.sh
index 5fc1ff8..dae65a0 100644
--- a/test/shell/lvconvert-thin-external-cache.sh
+++ b/test/shell/lvconvert-thin-external-cache.sh
@@ -50,6 +50,12 @@ not lvconvert --thin --thinpool $vg/tpool $vg/$lv1
 # Switch to 'writethrough' - this should be supported
 lvchange --cachemode writethrough $vg/$lv1
 
+# FIXME
+# systemd on fc23 'strikes-in' and unmounts  mnt
+# ATM the reason is unclear (bug in systemd, bad udev rules?)
+#   as a workaround mount again and 'WARN' test
+should not mount "$DM_DEV_DIR/$vg/$lv1" mnt
+
 lvconvert --thin $vg/$lv1 --originname extorg --thinpool $vg/tpool
 
 # check cache exist as extorg-real


