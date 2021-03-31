From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:00 +0000 (GMT)
Subject: dev-next - tests: wipefs with udev_wait
Message-ID: <20210331214900.AB2553858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93f2d194aca4a589cd38dd8bdd99cad2945dd21c
Commit:        93f2d194aca4a589cd38dd8bdd99cad2945dd21c
Parent:        14a3c34983fa8ab99773a47f1ee8bdd02d84feef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 14:57:10 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 14:57:10 2021 +0100

tests: wipefs with udev_wait

Try to synchronize with colliding udev.
Also retry once if there is some failure with some
sleep between next retry.

Use oflag=direct for wipping without wipefs.
---
 test/lib/aux.sh | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 20736260f..386918041 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -818,10 +818,16 @@ wipefs_a() {
 		echo "$have_wipefs" > HAVE_WIPEFS
 	fi
 
+	udev_wait
 	if [ "$have_wipefs" = "1" ] ; then
-		wipefs -a "$dev"
+		wipefs -a "$dev" || {
+			echo "$dev: device in-use, retrying wipe again."
+			sleep 1
+			udev_wait
+			wipefs -a "$dev"
+		}
 	else
-		dd if=/dev/zero of="$dev" bs=4096 count=8 >/dev/null || true
+		dd if=/dev/zero of="$dev" bs=4096 count=8 oflag=direct >/dev/null || true
 		mdadm --zero-superblock "$dev" 2>/dev/null || true
 	fi
 


