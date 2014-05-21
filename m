From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 15:00:43 +0000 (UTC)
Subject: master - tests: restore disable_dev behavior
Message-ID: <20140521150043.D2D726053A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c4953df1b5b2e2e509f6f89598a733d5d580f2b
Commit:        9c4953df1b5b2e2e509f6f89598a733d5d580f2b
Parent:        8db67d2aff7757d022f7d339451aeb93b0374311
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 16:59:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 16:59:38 2014 +0200

tests: restore disable_dev behavior

Notify needs to go  with major:minor before device disappears.
---
 test/lib/aux.sh |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e422fa0..01bc1ea 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -413,14 +413,9 @@ disable_dev() {
 		min=$(($(stat -L --printf=0x%T "$dev")))
 		echo "Disabling device $dev ($maj:$min)"
 		dmsetup remove -f "$dev" 2>/dev/null || true
-	done
-	finish_udev_transaction
-
-	for dev in "$@"; do
-		maj=$(($(stat -L --printf=0x%t "$dev")))
-		min=$(($(stat -L --printf=0x%T "$dev")))
 		notify_lvmetad --major "$maj" --minor "$min"
 	done
+	finish_udev_transaction
 }
 
 enable_dev() {


