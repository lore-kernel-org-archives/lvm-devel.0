From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 25 Apr 2014 21:58:39 +0000 (UTC)
Subject: master - test: Move the RAID vgsplit test into a separate file
Message-ID: <20140425215839.EBCE860E99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c671be434c15bf10b624ba8aaa43a378833179d5
Commit:        c671be434c15bf10b624ba8aaa43a378833179d5
Parent:        3c4234f825c93c9cd61409ade9039ba4033c8008
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 25 16:57:43 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 25 16:57:43 2014 -0500

test:  Move the RAID vgsplit test into a separate file

---
 test/shell/vgsplit-operation.sh |   22 ----------------------
 1 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 3a8a51a..201ad17 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -230,28 +230,6 @@ COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)"
 		  check pvlv_counts $vg2 1 1 0
 		fi
 		vgremove -f $vg1 $vg2
-
-if aux target_at_least dm-raid 1 1 0; then
-COMM "vgsplit correctly splits RAID LV into $i VG ($j args)"
-		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
-		test $i = existing && create_vg_ $vg2 "$dev5"
-
-		lvcreate -an -Zn -l 64 --type raid5 -i 2 -n $lv1 $vg1
-		if [ $j = PV ]; then
-		  not vgsplit $vg1 $vg2 "$dev1"
-		  not vgsplit $vg1 $vg2 "$dev2"
-		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
-		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
-		else
-		  vgsplit -n $lv1 $vg1 $vg2
-		fi
-		if [ $i = existing ]; then
-		  check pvlv_counts $vg2 4 1 0
-		else
-		  check pvlv_counts $vg2 3 1 0
-		fi
-		vgremove -f $vg2
-fi
 	done
 done
 


