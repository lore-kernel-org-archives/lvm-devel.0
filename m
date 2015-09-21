From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 21 Sep 2015 22:11:56 +0000 (UTC)
Subject: master - tests: check for block device
Message-ID: <20150921221156.E3D2160703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e63364529e563cf7609875f6aca10303c03883e
Commit:        7e63364529e563cf7609875f6aca10303c03883e
Parent:        2e5bde4a77d672ff763b5134055d4d35a753de6d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 21 22:42:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 00:08:44 2015 +0200

tests: check for block device

Need to detect if block device exist.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a59f98a..56316f7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -253,7 +253,7 @@ teardown_devs() {
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
 			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
-			for i in "${stray_loops[@]}" ; do test ! -f $i || losetup -d $i ; done
+			for i in "${stray_loops[@]}" ; do test ! -b $i || losetup -d $i ; done
 			# Leave test when udev processed all removed devices
 			udev_wait
 		}


