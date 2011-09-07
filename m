From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Sep 2011 08:31:19 -0000
Subject: LVM2 ./WHATS_NEW scripts/vgimportclone.sh test ...
Message-ID: <20110907083119.16078.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-07 08:31:17

Modified files:
	.              : WHATS_NEW 
	scripts        : vgimportclone.sh 
	test           : t-vgimportclone.sh 

Log message:
	Replace char class :space: with explicit chars
	
	Some major distributions are still using 'mawk' and they are not using
	the latest version - we end here with hidden dependency on the latest
	version of mawk (1.3.4) while i.e. Debian Lenny seems to stay with 1.3.3.
	So we end with completely broken  vgimportclone script on such system.
	
	We would need to check for proper support of :space: and abort build if
	it doesn't work or simplier replace [:space:] with [ \t] which seems
	sufficient to make it work (as can be seen in this patch)
	
	A better fix would be to use command line parameter override - leaving
	as FIXME comment.
	
	This patch makes t-vgimportclone.sh test passing on Lenny.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2094&r2=1.2095
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/vgimportclone.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgimportclone.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2011/09/06 18:49:31	1.2094
+++ LVM2/WHATS_NEW	2011/09/07 08:31:16	1.2095
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Replace :space: with [\t ] for awk in vgimportclone (not widely supported).
   Begin using 64-bit status field flags.
   Detect sscanf recovering_region input error in cmirrord pull_state().
   Fix error path bitmap leak in cmirrord import_checkpoint().
--- LVM2/scripts/vgimportclone.sh	2010/05/14 11:33:21	1.3
+++ LVM2/scripts/vgimportclone.sh	2011/09/07 08:31:17	1.4
@@ -242,13 +242,14 @@
 
 LVMCONF=${TMP_LVM_SYSTEM_DIR}/lvm.conf
 
+# FIXME convert to cmdline override
 "$LVM" dumpconfig ${LVM_OPTS} | \
 "$AWK" -v DEV=${TMP_LVM_SYSTEM_DIR} -v CACHE=${TMP_LVM_SYSTEM_DIR}/.cache \
     -v CACHE_DIR=${TMP_LVM_SYSTEM_DIR}/cache \
-    '/^[[:space:]]*filter[[:space:]]*=/{print ENVIRON["FILTER"];next} \
-     /^[[:space:]]*scan[[:space:]]*=/{print "scan = [ \"" DEV "\" ]";next} \
-     /^[[:space:]]*cache[[:space:]]*=/{print "cache = \"" CACHE "\"";next} \
-     /^[[:space:]]*cache_dir[[:space:]]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
+    '/^[ \t]*filter[ \t]*=/{print ENVIRON["FILTER"];next} \
+     /^[ \t]*scan[ \t]*=/{print "scan = [ \"" DEV "\" ]";next} \
+     /^[ \t]*cache[ \t]*=/{print "cache = \"" CACHE "\"";next} \
+     /^[ \t]*cache_dir[ \t]*=/{print "cache_dir = \"" CACHE_DIR "\"";next} \
      {print $0}' > ${LVMCONF}
 
 checkvalue $? "Failed to generate ${LVMCONF}"
@@ -282,7 +283,7 @@
 
 # output VG info so each line looks like: name:exported?:disk1,disk2,...
 VGINFO=`echo "${PVINFO}" | \
-    "$AWK" -F : '{{sub(/^[[:space:]]*/,"")} \
+    "$AWK" -F : '{{sub(/^[ \t]*/,"")} \
     {sub(/unknown device/,"unknown_device")} \
     {vg[$2]=$1","vg[$2]} if($3 ~ /^..x/){x[$2]="x"}} \
     END{for(k in vg){printf("%s:%s:%s\n", k, x[k], vg[k])}}'`
--- LVM2/test/t-vgimportclone.sh	2011/04/21 19:06:00	1.2
+++ LVM2/test/t-vgimportclone.sh	2011/09/07 08:31:17	1.3
@@ -1,4 +1,4 @@
-# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2010-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,25 +12,19 @@
 
 aux prepare_devs 2
 
-pvcreate $dev1 $dev2
-vgcreate $vg1 $dev1
+vgcreate -c n --metadatasize 128k $vg1 $dev1
 lvcreate -l100%FREE -n $lv1 $vg1
 
 # Clone the LUN
-dd if=$dev1 of=$dev2
+dd if=$dev1 of=$dev2 bs=256K count=1
 
 # Verify pvs works on each device to give us vgname
-pvs --noheadings -o vg_name $dev1 1>err
-grep $vg1 err
-pvs --noheadings -o vg_name $dev2 1>err
-grep $vg1 err
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
 
 # Import the cloned PV to a new VG
-# FIXME: this fails on lenny buildslave, I think we need proper wrapper
-# vgimportclone --basevgname $vg2 $dev2
+vgimportclone --basevgname $vg2 $dev2
 
 # Verify we can activate / deactivate the LV from both VGs
-# lvchange -ay $vg1/$lv1
-# lvchange -ay $vg2/$lv1
-# vgchange -an $vg1
-# vgchange -an $vg2
+lvchange -ay $vg1/$lv1 $vg2/$lv1
+vgchange -an $vg1 $vg2


