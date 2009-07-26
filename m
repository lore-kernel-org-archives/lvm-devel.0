From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 01:54:21 -0000
Subject: LVM2 lib/metadata/metadata.c tools/pvcreate.c
Message-ID: <20090726015421.6053.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 01:54:20

Modified files:
	lib/metadata   : metadata.c 
	tools          : pvcreate.c 

Log message:
	Move ORPHAN_VG lock outside pvcreate_single.
	
	The implicit pvcreate require either moving the ORPHAN_VG lock outside
	pvcreate_single or somehow having the function know or detect whether
	the ORPHAN_VG lock is already held.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.264&r2=1.265
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/lib/metadata/metadata.c	2009/07/26 01:53:57	1.264
+++ LVM2/lib/metadata/metadata.c	2009/07/26 01:54:20	1.265
@@ -1142,11 +1142,6 @@
 		}
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Can't get lock for orphan PVs");
-		return NULL;
-	}
-
 	if (!pvcreate_check(cmd, pv_name, pp))
 		goto error;
 
@@ -1203,11 +1198,9 @@
 
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
-	unlock_vg(cmd, VG_ORPHANS);
 	return pv;
 
       error:
-	unlock_vg(cmd, VG_ORPHANS);
 	return NULL;
 }
 
--- LVM2/tools/pvcreate.c	2009/07/26 01:53:09	1.82
+++ LVM2/tools/pvcreate.c	2009/07/26 01:54:20	1.83
@@ -171,9 +171,15 @@
 	}
 
 	for (i = 0; i < argc; i++) {
+		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+			log_error("Can't get lock for orphan PVs");
+			return ECMD_FAILED;
+		}
+
 		if (!pvcreate_single(cmd, argv[i], &pp))
 			ret = ECMD_FAILED;
 
+		unlock_vg(cmd, VG_ORPHANS);
 		if (sigint_caught())
 			return ret;
 	}


