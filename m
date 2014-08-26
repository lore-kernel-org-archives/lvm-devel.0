From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:43 +0000 (UTC)
Subject: master - tests: fix volume list test
Message-ID: <20140826121743.5776E60E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c37ca279e33b532f00da4b2f50e8e1ad547e8a77
Commit:        c37ca279e33b532f00da4b2f50e8e1ad547e8a77
Parent:        25fe716b123109dee83a593d3c354ffac13b06b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 26 12:09:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:13:07 2014 +0200

tests: fix volume list test

Proper use of \" escaping and shell vars.
---
 test/shell/lvchange-thin.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index cb9be53..4d33563 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -99,7 +99,7 @@ not lvchange --resync --addtag foo $vg/$lv1
 # Play with tags and activation
 #
 TAG=$(uname -n)
-aux lvmconf 'activation/volume_list = [ "$vg/$lv2", "@mytag", "$vg2" ]'
+aux lvmconf "activation/volume_list = [ \"$vg/$lv2\", \"@mytag\" ]"
 
 lvchange -ay $vg/$lv1
 check inactive $vg $lv1
@@ -123,9 +123,11 @@ not lvcreate -Zy -L10 -n $lv3 $vg2
 lvcreate -Zn -L10 -n $lv3 $vg2
 check inactive $vg2 $lv3
 
-aux lvmconf 'activation/volume_list = [ "$vg2" ]'
+aux lvmconf "activation/volume_list = [ \"$vg2\" ]"
 vgchange -an $vg
 vgchange -ay $vg $vg2
 lvs -a -o+lv_active $vg $vg2
 
+aux lvmconf "activation/volume_list = [ \"$vg\", \"$vg2\" ]"
+
 vgremove -ff $vg $vg2


