From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Oct 2020 19:37:01 +0000 (GMT)
Subject: stable-2.02 - tests: minor update
Message-ID: <20201025193701.6F05C388701C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a12574303d282779327bc93283edc72fd1b0772e
Commit:        a12574303d282779327bc93283edc72fd1b0772e
Parent:        4dcb35cb03021f1ae450078f3e8bf55c40751a56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 20:23:41 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 20:23:41 2020 +0100

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
 


