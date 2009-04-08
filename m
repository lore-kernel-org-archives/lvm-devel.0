From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 8 Apr 2009 12:53:21 -0000
Subject: LVM2 ./WHATS_NEW tools/commands.h tools/toollib.c
Message-ID: <20090408125321.8629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-08 12:53:20

Modified files:
	.              : WHATS_NEW 
	tools          : commands.h toollib.c 

Log message:
	Enable use of cached metadata for pvs & pvdisplay.
	
	Currently PV commands, which performs full device scan, repeatly
	re-reads PVs and scans for all devices.
	
	This behaviour can lead to OOM for large VG.
	
	This patch allows using internal metadata cache for pvs & pvdisplay,
	so the commands scan the PVs only once.
	(We have to use VG_GLOBAL otherwise cache is invalidated on every
	VG unlock in process_single PV call.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1078&r2=1.1079
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146

--- LVM2/WHATS_NEW	2009/04/07 22:53:48	1.1078
+++ LVM2/WHATS_NEW	2009/04/08 12:53:20	1.1079
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Enable use of cached metadata for pvs and pvdisplay commands.
   Add missing 'device-mapper' internal subdir build dependency.
   Fix memory leak in mirror allocation code.
   Save and restore the previous logging level when log level is changed.
--- LVM2/tools/commands.h	2009/02/22 19:00:28	1.122
+++ LVM2/tools/commands.h	2009/04/08 12:53:20	1.123
@@ -497,7 +497,7 @@
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   0,
+   CACHE_VGMETADATA,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[-d|--debug]\n"
@@ -571,7 +571,7 @@
 
 xx(pvs,
    "Display information about physical volumes",
-   0,
+   CACHE_VGMETADATA,
    "pvs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
--- LVM2/tools/toollib.c	2009/04/07 10:22:14	1.145
+++ LVM2/tools/toollib.c	2009/04/08 12:53:20	1.146
@@ -633,6 +633,11 @@
 	return ret_max;
 }
 
+/*
+ * If the lock_type is LCK_VG_READ (used only in reporting commands),
+ * we lock VG_GLOBAL to enable use of metadata cache.
+ * This can pause alongide pvscan or vgscan process for a while.
+ */
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    struct volume_group *vg, uint32_t lock_type,
 		    int scan_label_only, void *handle,
@@ -644,6 +649,7 @@
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
+	int lock_global = lock_type == LCK_VG_READ;
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;
@@ -656,6 +662,11 @@
 
 	dm_list_init(&tags);
 
+	if (lock_global && !lock_vol(cmd, VG_GLOBAL, lock_type)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
@@ -673,7 +684,7 @@
 						  dm_pool_strdup(cmd->mem,
 							      tagname))) {
 					log_error("strlist allocation failed");
-					return ECMD_FAILED;
+					goto bad;
 				}
 				continue;
 			}
@@ -727,7 +738,7 @@
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
-				return ret_max;
+				goto out;
 		}
 		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
 			   !dm_list_empty(vgnames)) {
@@ -761,7 +772,7 @@
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
-					return ret_max;
+					goto out;
 			}
 		}
 	} else {
@@ -773,17 +784,18 @@
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
-				return ret_max;
+				goto out;
 		} else if (arg_count(cmd, all_ARG)) {
 			ret = _process_all_devs(cmd, handle, process_single);
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
-				return ret_max;
+				goto out;
 		} else {
 			log_verbose("Scanning for physical volume names");
+
 			if (!(pvslist = get_pvs(cmd)))
-				return ECMD_FAILED;
+				goto bad;
 
 			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single(cmd, NULL, pvl->pv,
@@ -791,12 +803,19 @@
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
-					return ret_max;
+					goto out;
 			}
 		}
 	}
-
+out:
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
 	return ret_max;
+bad:
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
+	return ECMD_FAILED;
 }
 
 /*


