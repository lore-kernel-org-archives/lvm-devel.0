From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:46 +0000 (UTC)
Subject: master - tests: do not break teardown on failing losetup
Message-ID: <20160406095546.BA1F660F2B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=307ab2c179073d28d1c9ec9f995f2849aeab07c6
Commit:        307ab2c179073d28d1c9ec9f995f2849aeab07c6
Parent:        07c25429e2b1eb08bb208a6bae015870c7ae635a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 1 09:36:23 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:54:37 2016 +0200

tests: do not break teardown on failing losetup

Ignore failing 'losetup -d' - i.e. device may have disappeared...
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9fd1922..c8985ed 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -431,7 +431,7 @@ teardown_devs() {
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
 			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
-			for i in "${stray_loops[@]}" ; do test ! -b $i || losetup -d $i ; done
+			for i in "${stray_loops[@]}" ; do test ! -b $i || losetup -d $i || true ; done
 			# Leave test when udev processed all removed devices
 			udev_wait
 		}


