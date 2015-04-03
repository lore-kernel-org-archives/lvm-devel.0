From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 18:15:49 +0000 (UTC)
Subject: master - tests: skip clvmd testing of mirrored LV vgsplit
Message-ID: <20150403181549.1E86E6103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba049e203b35d6e03e38669a2a92af6538a0b2d0
Commit:        ba049e203b35d6e03e38669a2a92af6538a0b2d0
Parent:        87cb0a3e9ff3efb35d9383a9044f683e28f41776
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 20:14:26 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 20:14:26 2015 +0200

tests: skip clvmd testing of mirrored LV vgsplit

There is something wrong when even inactive LV can't be splitted
without cmirrord being present for clustered VG.
---
 test/shell/vgsplit-operation.sh |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 6b478e8..f2baafd 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -119,9 +119,12 @@ COMM "vgsplit correctly splits mirror (log+leg on same dev) into $i VG ($j args)
 		lvremove -f $vg2/$lv1
 		vgremove -f $vg1 $vg2
 
+# Can't use mirrored log without cmirrord
+# TODO: Should work for inactive device, needs some fixes....
+if test ! -e LOCAL_CLVMD ; then
 COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
-		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-		test $i = existing && create_vg_ -c n $vg2 "$dev5"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+		test $i = existing && create_vg_ $vg2 "$dev5"
 
 		lvcreate -an -Zn -l 64 --mirrorlog mirrored --type mirror -m1 -n $lv1 $vg1 \
 		    "$dev1" "$dev2" "$dev3" "$dev4"
@@ -146,8 +149,8 @@ COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
 
 # RHBZ 875903
 COMM "vgsplit correctly splits mirror LV with mirrored log on same devs into $i VG ($j args)"
-		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-		test $i = existing && create_vg_ -c n $vg2 "$dev5"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+		test $i = existing && create_vg_ $vg2 "$dev5"
 
 		lvcreate -an -Zn -l 64 --mirrorlog mirrored --type mirror -m1 -n $lv1 $vg1 \
 		    "$dev1" "$dev2"
@@ -166,6 +169,7 @@ COMM "vgsplit correctly splits mirror LV with mirrored log on same devs into $i
 		fi
 		lvremove -f $vg2/$lv1
 		vgremove -f $vg1 $vg2
+fi
 
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2"


