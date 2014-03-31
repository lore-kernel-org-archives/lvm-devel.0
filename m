From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:51 +0000 (UTC)
Subject: master - tests: add more rename test
Message-ID: <20140331100651.10B9E60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=367e4551a1f1ef81f4ed3cc0200247a571af78e8
Commit:        367e4551a1f1ef81f4ed3cc0200247a571af78e8
Parent:        ee8708cc8ebfcbb55800e6ca8782394b5f3db2f7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 11:44:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:05:35 2014 +0200

tests: add more rename test

Drop test, which are now in other files (listings.sh)
---
 test/shell/covercmd.sh |   25 +++++++++----------------
 1 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index d9a5382..a036d92 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -21,38 +21,31 @@ aux prepare_pvs 5
 pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 
-pvscan --uuid
-
 # FIXME takes very long time
 #pvck "$dev1"
 
-
 vgcreate $vg $(cat DEVICES)
-not vgscan $vg
-vgscan --mknodes
-vgs -o all $vg
 
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 lvcreate -aey -l 5 -n $lv1 $vg
 lvcreate -s -l 5 -n $lv2 $vg/$lv1
 pvck "$dev1"
 
-not lvscan $vg
-lvscan
-
-lvmdiskscan
-
 # "-persistent y --major 254 --minor 20"
 # "-persistent n"
-for i in pr "p rw" an ay "-monitor y" "-monitor n" \
-        -refresh "-addtag MYTAG" "-deltag MYETAG"; do
+for i in pr "p rw" "-monitor y" "-monitor n" -refresh; do
 	lvchange -$i $vg/$lv
 done
 
 lvrename $vg $lv $lv-rename
-not lvrename $vg
-not lvrename $vg-xxx
-not lvrename $vg $vg/$lv-rename $vg1/$lv
+invalid lvrename $vg
+invalid lvrename $vg $vg/$lv-rename $vg1/$lv
+invalid lvrename $vg/$lv-rename $vg1/$lv $vg
+invalid lvrename $vg/$lv-rename $vg/012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
+invalid lvrename $vg/$lv-rename $vg/""
+invalid lvrename $vg/$lv-rename "$vg/!@#$%"
+invalid lvrename $vg/$lv-rename $vg/$lv-rename
+fail lvrename $vg1/$lv-rename $vg1/$lv
 
 vgremove -f $vg
 


