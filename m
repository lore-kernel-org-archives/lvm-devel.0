From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 23:06:56 +0000 (UTC)
Subject: master - tests: dd needs to fail in this case
Message-ID: <20150502230656.9DC04607B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75aa3e951f2e22a790fe2425f3b3ef71f292be2e
Commit:        75aa3e951f2e22a790fe2425f3b3ef71f292be2e
Parent:        224e30a4b18e66f3c269ed97a1ab14229d3e7ec7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 3 01:06:20 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 01:06:20 2015 +0200

tests: dd needs to fail in this case

---
 test/shell/snapshot-autoumount-dmeventd.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index db4062e..e059684 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -32,7 +32,7 @@ mkdir "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 mount
 cat /proc/mounts | grep "$mntdir"
-dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 oflag=direct
+not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 oflag=direct
 
 #dmeventd only checks every 10 seconds :(
 for i in {1..10}; do


