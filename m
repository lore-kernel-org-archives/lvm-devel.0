From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Jun 2010 12:45:12 -0000
Subject: LVM2 ./WHATS_NEW test/t-activate-partial.sh to ...
Message-ID: <20100603124512.20343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-03 12:45:09

Modified files:
	.              : WHATS_NEW 
	test           : t-activate-partial.sh 
	tools          : toollib.c 

Log message:
	Require partial option in lvchange --refresh for partials LVs.
	
	We must not refresh LV if some PVs are missing and partial activation
	was not requested.
	
	Fixes https://bugzilla.redhat.com/show_bug.cgi?id=598886

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1603&r2=1.1604
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-partial.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.201&r2=1.202

--- LVM2/WHATS_NEW	2010/06/01 21:47:57	1.1603
+++ LVM2/WHATS_NEW	2010/06/03 12:45:05	1.1604
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Require partial option in lvchange --refresh for partial LVs.
   Do not fail lvm_init() if init_logging() or _init_rand() generates an errno.
   Don't merge unchanged persistent cache file before dumping if tool scanned.
   Fix incorrect memory pool deallocation while using vg_read for files.
--- LVM2/test/t-activate-partial.sh	2010/05/12 05:59:24	1.1
+++ LVM2/test/t-activate-partial.sh	2010/06/03 12:45:09	1.2
@@ -9,6 +9,8 @@
 not vgreduce --removemissing $vg
 not lvchange -v -a y $vg/mirror
 lvchange -v --partial -a y $vg/mirror
+not lvchange -v --refresh $vg/mirror
+lvchange -v --refresh --partial $vg/mirror
 
 # also check that vgchange works
 vgchange -a n --partial $vg
--- LVM2/tools/toollib.c	2010/05/21 14:15:39	1.201
+++ LVM2/tools/toollib.c	2010/06/03 12:45:09	1.202
@@ -1248,6 +1248,12 @@
 {
 	int r = 0;
 
+	if (!cmd->partial_activation && (lv->status & PARTIAL_LV)) {
+		log_error("Refusing refresh of partial LV %s. Use --partial to override.",
+			  lv->name);
+		goto out;
+	}
+
 	r = suspend_lv(cmd, lv);
 	if (!r)
 		goto_out;


