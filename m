From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:15 +0000 (UTC)
Subject: master - tests: simplify
Message-ID: <20140321213215.9A93460F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b1916fd5a5640f357ea50b806840d3981661de6
Commit:        8b1916fd5a5640f357ea50b806840d3981661de6
Parent:        de5683d8d96613f37a21ed37695a5399c03a9257
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 23:33:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:28 2014 +0100

tests: simplify

---
 test/shell/lvcreate-signature-wiping.sh |    8 ++------
 test/shell/thin-merge.sh                |    1 -
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvcreate-signature-wiping.sh b/test/shell/lvcreate-signature-wiping.sh
index 5618780..be06bce 100644
--- a/test/shell/lvcreate-signature-wiping.sh
+++ b/test/shell/lvcreate-signature-wiping.sh
@@ -13,9 +13,7 @@
 
 . lib/test
 
-aux prepare_devs 1
-aux pvcreate -f $dev1
-aux vgcreate $vg $dev1
+aux prepare_vg
 
 # lvcreate wipes signatures when found on newly created LV - test this on "swap".
 # Test all combinatios with -Z{y|n} and -W{y|n} and related lvm.conf settings.
@@ -92,6 +90,4 @@ mkswap "$DM_DEV_DIR/$vg/$lv1"
 blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep "swap"
 lvremove -f $vg/$lv1
 
-
-vgremove $vg
-pvremove $dev1
+vgremove -f $vg
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 7eb137e..60234a6 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -76,7 +76,6 @@ lvchange -an $vg/$lv1
 not lvchange -K -ay $vg/snap
 
 lvs -a -o +tags,thin_id $vg
-dmsetup table
 
 # Test if merge happens
 lvchange -ay $vg/$lv1


