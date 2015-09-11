From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:42 +0000 (UTC)
Subject: master - tests: wait for sync before deactivation
Message-ID: <20150911195442.0F236611FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=226e7d7b3c30f083c422063ec107c50b3534ee0f
Commit:        226e7d7b3c30f083c422063ec107c50b3534ee0f
Parent:        cd2e4310b320782ec58b712d3c2f24a56c7d10c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 20:54:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:27 2015 +0200

tests: wait for sync before deactivation

On slower machine/disk, sync may block udev from reading and may prevent
deactivation.
---
 test/shell/lvresize-raid.sh |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 1a1a75f..333318a 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -24,7 +24,10 @@ for deactivate in true false; do
 # Extend and reduce a 2-way RAID1
 	lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
 
-	test $deactivate && lvchange -an $vg/$lv1
+	test $deactivate && {
+		aux wait_for_sync $vg $lv1
+		lvchange -an $vg/$lv1
+	}
 
 	lvresize -l +2 $vg/$lv1
 
@@ -36,7 +39,10 @@ for deactivate in true false; do
 	for i in 4 5 6 ; do
 		lvcreate --type raid$i -i 3 -l 3 -n $lv2 $vg
 
-		test $deactivate && lvchange -an $vg/$lv2
+		test $deactivate && {
+			aux wait_for_sync $vg $lv2
+			lvchange -an $vg/$lv2
+		}
 
 		lvresize -l +3 $vg/$lv2
 


