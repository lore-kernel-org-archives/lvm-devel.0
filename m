From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 25 Apr 2014 21:26:13 +0000 (UTC)
Subject: master - test/vgsplit-operation.sh: Add vgsplit tests for RAID
Message-ID: <20140425212613.27A1A61518@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dffb9fca9dba16bba0ec41ecc16ed42fe2dd4cf
Commit:        4dffb9fca9dba16bba0ec41ecc16ed42fe2dd4cf
Parent:        76687f4cacd6ca3f8953d4ee915efc159838cd91
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 25 16:22:40 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 25 16:22:40 2014 -0500

test/vgsplit-operation.sh: Add vgsplit tests for RAID

vgsplit of RAID volumes was problematic because the metadata area
and data areas were always on the same PVs.  This problem is similar
to one that was just fixed for mirrors that had log and images sharing
a PV (commit 9ac858f).  We can now add RAID LVs to the tests for
vgsplit.

Note that there still seems to be an issue when specifying an
incomplete set of PVs when moving RAID LVs.
---
 test/shell/vgsplit-operation.sh |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 097f0f5..5dbff69 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -231,6 +231,27 @@ COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)"
 		fi
 		vgremove -f $vg1 $vg2
 
+if aux target_at_least dm-raid 1 1 0; then
+COMM "vgsplit correctly splits RAID LV into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
+		test $i = existing && create_vg_ $vg2 "$dev5"
+
+		lvcreate -an -Zn -l 64 --type raid5 -i 2 -n $lv1 $vg1
+		if [ $j = PV ]; then
+#		  not vgsplit $vg1 $vg2 "$dev1"
+#		  not vgsplit $vg1 $vg2 "$dev2"
+#		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 4 1 0
+		else
+		  check pvlv_counts $vg2 3 1 0
+		fi
+		vgremove -f $vg2
+fi
 	done
 done
 


