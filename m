From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:50 -0400
Subject: master - tests: fix running tests on systems without udevd
Message-ID: <201803151004.w2FA4oqv023713@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=750fc2e876f49d48e8f883e4e342338b8c4676cd
Commit:        750fc2e876f49d48e8f883e4e342338b8c4676cd
Parent:        285413b502e1f0f5a016b24c93b871419381c1fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 14 11:23:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 11:01:04 2018 +0100

tests: fix running tests on systems without udevd

Variable was unbound on systems without running udevd.
---
 test/lib/utils.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index a1f7a01..b6c2ab0 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -209,8 +209,8 @@ init_udev_transaction() {
 }
 
 finish_udev_transaction() {
-	if test "$DM_UDEV_SYNCHRONISATION" = 1 && test -n "$DM_UDEV_COOKIE" ; then
-		dmsetup udevreleasecookie
+	if test "$DM_UDEV_SYNCHRONISATION" = 1 && test -n "${DM_UDEV_COOKIE-}" ; then
+		dmsetup udevreleasecookie || true
 		unset DM_UDEV_COOKIE
 	fi
 }


