From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:30:06 +0000 (UTC)
Subject: master - tests: remove only existing loops
Message-ID: <20150910153006.4EEB360AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b8c876293b883f6c84d349d04e20a77facb69d1
Commit:        9b8c876293b883f6c84d349d04e20a77facb69d1
Parent:        e94ab01940828f471a9498f112d2023c3bf06ffd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 9 09:40:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:28:47 2015 +0200

tests: remove only existing loops

If loop device meanwhile dissapered, skip 'losetup -d' call.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 25700f6..a59f98a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -253,7 +253,7 @@ teardown_devs() {
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
 			echo "Removing stray loop devices containing $COMMON_PREFIX: ${stray_loops[@]}"
-			for i in "${stray_loops[@]}" ; do losetup -d $i ; done
+			for i in "${stray_loops[@]}" ; do test ! -f $i || losetup -d $i ; done
 			# Leave test when udev processed all removed devices
 			udev_wait
 		}


