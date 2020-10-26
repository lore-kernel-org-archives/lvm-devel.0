From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Oct 2020 14:21:24 +0000 (GMT)
Subject: master - tests: minor update
Message-ID: <20201026142124.718BA388EC18@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e793f34eb73bd4be5a37ed641f9fe11ad1a6d578
Commit:        e793f34eb73bd4be5a37ed641f9fe11ad1a6d578
Parent:        b0333841352b76ce13464b82cb1876ea82b80351
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 20:23:41 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 13:06:52 2020 +0100

tests: minor update

---
 test/shell/fsadm.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 3e7f9083c..910edddd8 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -54,8 +54,8 @@ test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
 
 cleanup_mounted_and_teardown()
 {
-	umount "$mount_dir" || true
-	umount "$mount_space_dir" || true
+	umount "$mount_dir" 2>/dev/null || true
+	umount "$mount_space_dir" 2>/dev/null || true
 	aux teardown
 }
 


