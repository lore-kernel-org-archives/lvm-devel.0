From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Mar 2012 20:00:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c tes ...
Message-ID: <20120315200056.13821.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-03-15 20:00:54

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 
	test/shell     : lvconvert-raid.sh 

Log message:
	Fix name conflicts that prevent down-converting RAID1 when specifying a device
	
	When down-converting a RAID1 device, it is the last device that is extracted
	and removed when the user does not specify a particular device.  However,
	when a device is specified (and it is not the last), the device is removed and
	the remaining sub-LVs are "shifted down" to fill the hole.  This cause problems
	when resuming the LV because if the shifted devices were resumed (and thus
	renamed) before the sub-LV being extracted, there would be a name conflict.
	The solution is to resume the extracted sub-LVs first so that they can be
	properly renamed preventing a possible conflict.
	
	This addresses bug 801967.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2356&r2=1.2357
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2012/03/14 17:12:05	1.2356
+++ LVM2/WHATS_NEW	2012/03/15 20:00:54	1.2357
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix name conflicts that prevent down-converting RAID1 when specifying a device
   Improve thin_check option passing and use configured path.
   Add --with-thin-check configure option for path to thin_check.
   Detect lvm binary path in lvmetad udev rules.
--- LVM2/lib/metadata/raid_manip.c	2012/02/23 17:36:36	1.24
+++ LVM2/lib/metadata/raid_manip.c	2012/03/15 20:00:54	1.25
@@ -1012,8 +1012,20 @@
 	}
 
 	/*
+	 * We resume the extracted sub-LVs first so they are renamed
+	 * and won't conflict with the remaining (possibly shifted)
+	 * sub-LVs.
+	 */
+	dm_list_iterate_items(lvl, &removal_list) {
+		if (!resume_lv(lv->vg->cmd, lvl->lv)) {
+			log_error("Failed to resume extracted LVs");
+			return 0;
+		}
+	}
+
+	/*
 	 * Resume original LV
-	 * This also resumes all other sub-lvs (including the extracted)
+	 * This also resumes all other sub-LVs
 	 */
 	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
--- LVM2/test/shell/lvconvert-raid.sh	2012/03/04 16:02:19	1.3
+++ LVM2/test/shell/lvconvert-raid.sh	2012/03/15 20:00:54	1.4
@@ -156,6 +156,13 @@
 	done
 done
 done
+
+# 3-way to 2-way convert while specifying devices
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
+wait_for_sync $vg/$lv1
+lvconvert -m1 $vg/$lv1 $dev2
+lvremove -ff $vg
+
 #
 # FIXME: Add tests that specify particular devices to be removed
 #


