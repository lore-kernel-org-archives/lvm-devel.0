From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 May 2009 13:03:02 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c tools/v ...
Message-ID: <20090513130302.17875.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-13 13:02:58

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	tools          : vgcfgrestore.c vgcreate.c vgextend.c vgmerge.c 
	                 vgreduce.c vgremove.c vgrename.c vgsplit.c 

Log message:
	Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
	
	As a simplification to the tools and further liblvm, this patch pushes
	the setting of NON_BLOCKING lock flag inside the lock_vol() call.
	The policy we set is if any existing VGs are currently locked, we
	set the NON_BLOCKING flag.
	
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1101&r2=1.1102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2009/05/12 19:12:09	1.1101
+++ LVM2/WHATS_NEW	2009/05/13 13:02:52	1.1102
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
   Remove snapshot_count from VG and use function instead.
   Fix first_seg() call for empty segment list.
   Add make install_lvm2 as complement to device-mapper install.
--- LVM2/lib/locking/locking.c	2009/02/22 16:13:57	1.56
+++ LVM2/lib/locking/locking.c	2009/05/13 13:02:55	1.57
@@ -376,6 +376,14 @@
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
+		/*
+		 * Automatically set LCK_NONBLOCK if one or more VGs locked.
+		 * This will enforce correctness and prevent deadlocks rather
+		 * than relying on the caller to set the flag properly.
+		 */
+		if (vgs_locked())
+			flags |= LCK_NONBLOCK;
+
 		/* Lock VG to change on-disk metadata. */
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))
--- LVM2/tools/vgcfgrestore.c	2008/01/30 14:00:02	1.18
+++ LVM2/tools/vgcfgrestore.c	2009/05/13 13:02:55	1.19
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -48,7 +48,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
--- LVM2/tools/vgcreate.c	2009/04/10 10:01:39	1.59
+++ LVM2/tools/vgcreate.c	2009/05/13 13:02:56	1.60
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -51,7 +51,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
--- LVM2/tools/vgextend.c	2009/04/10 10:01:39	1.38
+++ LVM2/tools/vgextend.c	2009/05/13 13:02:56	1.39
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -42,7 +42,7 @@
 	}
 
 	log_verbose("Checking for volume group \"%s\"", vg_name);
-	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE | LCK_NONBLOCK,
+	if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_WRITE,
 				    CLUSTERED | EXPORTED_VG |
 				    LVM_WRITE | RESIZEABLE_VG,
 				    CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
--- LVM2/tools/vgmerge.c	2009/05/12 19:12:10	1.52
+++ LVM2/tools/vgmerge.c	2009/05/13 13:02:56	1.53
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -35,7 +35,7 @@
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 	if (!(vg_from = vg_lock_and_read(cmd, vg_name_from, NULL,
-					 LCK_VG_WRITE | LCK_NONBLOCK,
+					 LCK_VG_WRITE,
 					 CLUSTERED | EXPORTED_VG | LVM_WRITE,
 					 CORRECT_INCONSISTENT | FAIL_INCONSISTENT))) {
 		unlock_release_vg(cmd, vg_to, vg_name_to);
--- LVM2/tools/vgreduce.c	2009/04/22 17:00:31	1.89
+++ LVM2/tools/vgreduce.c	2009/05/13 13:02:56	1.90
@@ -397,7 +397,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;
 	}
--- LVM2/tools/vgremove.c	2008/01/30 14:00:02	1.46
+++ LVM2/tools/vgremove.c	2009/05/13 13:02:56	1.47
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -41,7 +41,7 @@
 	}
 
 	ret = process_each_vg(cmd, argc, argv,
-			      LCK_VG_WRITE | LCK_NONBLOCK, 1,
+			      LCK_VG_WRITE, 1,
 			      NULL, &vgremove_single);
 
 	unlock_vg(cmd, VG_ORPHANS);
--- LVM2/tools/vgrename.c	2009/04/10 10:01:39	1.60
+++ LVM2/tools/vgrename.c	2009/05/13 13:02:56	1.61
@@ -100,7 +100,7 @@
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
-	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE)) {
 		unlock_release_vg(cmd, vg, vg_name_old);
 		log_error("Can't get lock for %s", vg_name_new);
 		return 0;
--- LVM2/tools/vgsplit.c	2009/05/12 19:12:10	1.71
+++ LVM2/tools/vgsplit.c	2009/05/13 13:02:56	1.72
@@ -325,7 +325,7 @@
 		 return ECMD_FAILED;
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
-	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE | LCK_NONBLOCK)) {
+	if (!lock_vol(cmd, vg_name_to, LCK_VG_WRITE)) {
 		log_error("Can't get lock for %s", vg_name_to);
 		unlock_release_vg(cmd, vg_from, vg_name_from);
 		return ECMD_FAILED;


