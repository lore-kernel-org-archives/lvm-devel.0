From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  5 Sep 2012 16:39:25 +0000 (UTC)
Subject: master - TEST (lvresize-raid): Also test resizing of RAID10
Message-ID: <20120905163925.9E880A0DA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b01a2f65a27b95717fa7b6d912271e330782873
Commit:        1b01a2f65a27b95717fa7b6d912271e330782873
Parent:        967b5eb1f3a25572448974f882e3bc8ba5d3fb9a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 24 16:20:53 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 5 11:33:07 2012 -0500

TEST (lvresize-raid):  Also test resizing of RAID10

---
 test/shell/lvresize-raid.sh |   35 +++++++++++++++++++++++++++++++++--
 1 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index ea5cc80..e78eb8c 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -38,7 +38,7 @@ for deactivate in true false; do
 		lvchange -an $vg/$lv1
 	fi
 
-	should lvresize -l -2 $vg/$lv1
+	should lvresize -y -l -2 $vg/$lv1
 
 	#check raid_images_contiguous $vg $lv1
 
@@ -71,10 +71,41 @@ for i in 4 5 6 ; do
 			lvchange -an $vg/$lv1
 		fi
 
-		should lvresize -l -3 $vg/$lv1
+		should lvresize -y -l -3 $vg/$lv1
 
 		#check raid_images_contiguous $vg $lv1
 
 		lvremove -ff $vg
 	done
 done
+
+# Extend RAID10 (2-stripes, 2-mirror)
+for deactivate in true false; do
+	lvcreate --type raid10 -m 1 -i 2 -l 2 -n $lv1 $vg
+
+	if $deactivate; then
+		lvchange -an $vg/$lv1
+	fi
+
+	lvresize -l +2 $vg/$lv1
+
+	#check raid_images_contiguous $vg $lv1
+
+	lvremove -ff $vg
+done
+
+# Reduce RAID10 (2-stripes, 2-mirror)
+for deactivate in true false; do
+	lvcreate --type raid10 -m 1 -i 2 -l 4 -n $lv1 $vg
+
+	if $deactivate; then
+		lvchange -an $vg/$lv1
+	fi
+
+	should lvresize -y -l -2 $vg/$lv1
+
+	#check raid_images_contiguous $vg $lv1
+
+	lvremove -ff $vg
+done
+


