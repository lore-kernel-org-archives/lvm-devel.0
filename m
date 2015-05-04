From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 08:21:33 +0000 (UTC)
Subject: master - tests: check for open_count
Message-ID: <20150504082133.3C33C60F2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d10a6f6aef9eb013986c40a8bd83db6f571472f
Commit:        2d10a6f6aef9eb013986c40a8bd83db6f571472f
Parent:        7a588bce7bd032175d56a1a10af528d61e1c554b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 10:18:44 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 10:18:44 2015 +0200

tests: check for open_count

Instead of checking /proc/mounts check for open_count of snap device.
Parallel umount has race, so check for open_count.
---
 test/shell/snapshot-autoumount-dmeventd.sh |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index e059684..860d170 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -30,14 +30,17 @@ lvchange --monitor y $vg/snap
 
 mkdir "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
-mount
+
 cat /proc/mounts | grep "$mntdir"
 not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 oflag=direct
 
-#dmeventd only checks every 10 seconds :(
-for i in {1..10}; do
-	cat /proc/mounts | grep "$mntdir" || break
-	sleep 1
+# Should be nearly instant check of dmeventd for invalid snapshot.
+# Wait here for umount and open_count drops to 0 as it may
+# take a while to finalize umount operation (it might be already
+# removed from /proc/mounts, but still opened).
+for i in {1..100}; do
+	test $(dmsetup info -c --noheadings -o open $vg-snap) -eq 0 && break
+	sleep .1
 done
 
 cat /proc/mounts | not grep "$mntdir"


