From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Apr 2023 09:26:29 +0000 (GMT)
Subject: main - tests: hide some more file in error trace
Message-ID: <20230422092629.D8F2D3858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbc67abeed8a7a5f4a31c6dd0d3bf4cb26c6a50a
Commit:        bbc67abeed8a7a5f4a31c6dd0d3bf4cb26c6a50a
Parent:        f239ce2353504f1a69fd7cc5386067cffd71b965
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 22 11:23:04 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 22 11:25:39 2023 +0200

tests: hide some more file in error trace

Hide unneeded dev nodes.
---
 test/lib/utils.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index ca9f5ec61..5e462605f 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -190,7 +190,8 @@ STACKTRACE() {
 			dmsetup ls --tree | sed -e "s,^,## DMTREE:   ,"
 			echo "<======== Recursive list of $DM_DEV_DIR ========>"
 			ls -Rl --hide=shm --hide=bus --hide=snd --hide=input --hide=dri \
-			       --hide=net --hide=hugepages --hide=mqueue --hide=pts \
+				--hide=net --hide=hugepages --hide=mqueue --hide=pts \
+				--hide=tty?*  --hide=vcs?* --hide=usb --hide=char \
 			       "$DM_DEV_DIR" | sed -e "s,^,## LSLR:	,"
 			echo "<======== Udev DB content ========>"
 			for i in /sys/block/dm-* /sys/block/loop* ; do

