From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 10:34:12 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/comm ...
Message-ID: <20100401103412.555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 10:34:11

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c 
	lib/config     : config.c 
	lib/device     : dev-io.c 
	lib/format1    : import-export.c 
	lib/format_text: import_vsn1.c 
	lib/locking    : locking.c 
	lib/metadata   : lv_manip.c 
	tools          : pvscan.c 

Log message:
	Change most remaining log_error WARNING messages to log_warn.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1498&r2=1.1499
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW	2010/03/31 17:23:56	1.1498
+++ LVM2/WHATS_NEW	2010/04/01 10:34:09	1.1499
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Change most remaining log_error WARNING messages to log_warn.
   Always use blocking lock for VGs and orphan locks.
   Allocate all segments memory from vg private mempool.
   Return newly allocated PV segment after segment split.
--- LVM2/lib/cache/lvmcache.c	2010/03/31 17:20:44	1.83
+++ LVM2/lib/cache/lvmcache.c	2010/04/01 10:34:09	1.84
@@ -903,37 +903,37 @@
 		 */
 		if (!(primary_vginfo->status & EXPORTED_VG) &&
 		    (vgstatus & EXPORTED_VG))
-			log_error("WARNING: Duplicate VG name %s: "
-				  "Existing %s takes precedence over "
-				  "exported %s", new_vginfo->vgname,
-				  uuid_primary, uuid_new);
+			log_warn("WARNING: Duplicate VG name %s: "
+				 "Existing %s takes precedence over "
+				 "exported %s", new_vginfo->vgname,
+				 uuid_primary, uuid_new);
 		else if ((primary_vginfo->status & EXPORTED_VG) &&
 			   !(vgstatus & EXPORTED_VG)) {
-			log_error("WARNING: Duplicate VG name %s: "
-				  "%s takes precedence over exported %s",
-				  new_vginfo->vgname, uuid_new,
-				  uuid_primary);
+			log_warn("WARNING: Duplicate VG name %s: "
+				 "%s takes precedence over exported %s",
+				 new_vginfo->vgname, uuid_new,
+				 uuid_primary);
 			use_new = 1;
 		} else if (primary_vginfo->creation_host &&
 			   !strcmp(primary_vginfo->creation_host,
 				   primary_vginfo->fmt->cmd->hostname))
-			log_error("WARNING: Duplicate VG name %s: "
-				  "Existing %s (created here) takes precedence "
-				  "over %s", new_vginfo->vgname, uuid_primary,
-				  uuid_new);
+			log_warn("WARNING: Duplicate VG name %s: "
+				 "Existing %s (created here) takes precedence "
+				 "over %s", new_vginfo->vgname, uuid_primary,
+				 uuid_new);
 		else if (!primary_vginfo->creation_host && creation_host) {
-			log_error("WARNING: Duplicate VG name %s: "
-				  "%s (with creation_host) takes precedence over %s",
-				  new_vginfo->vgname, uuid_new,
-				  uuid_primary);
+			log_warn("WARNING: Duplicate VG name %s: "
+				 "%s (with creation_host) takes precedence over %s",
+				 new_vginfo->vgname, uuid_new,
+				 uuid_primary);
 			use_new = 1;
 		} else if (creation_host &&
 			   !strcmp(creation_host,
 				   primary_vginfo->fmt->cmd->hostname)) {
-			log_error("WARNING: Duplicate VG name %s: "
-				  "%s (created here) takes precedence over %s",
-				  new_vginfo->vgname, uuid_new,
-				  uuid_primary);
+			log_warn("WARNING: Duplicate VG name %s: "
+				 "%s (created here) takes precedence over %s",
+				 new_vginfo->vgname, uuid_new,
+				 uuid_primary);
 			use_new = 1;
 		}
 
--- LVM2/lib/commands/toolcontext.c	2010/03/09 03:16:11	1.92
+++ LVM2/lib/commands/toolcontext.c	2010/04/01 10:34:09	1.93
@@ -233,8 +233,8 @@
 	}
 
 	if (*cmd->proc_dir && !dir_exists(cmd->proc_dir)) {
-		log_error("WARNING: proc dir %s not found - some checks will be bypassed",
-			  cmd->proc_dir);
+		log_warn("WARNING: proc dir %s not found - some checks will be bypassed",
+			 cmd->proc_dir);
 		cmd->proc_dir[0] = '\0';
 	}
 
--- LVM2/lib/config/config.c	2009/10/22 10:38:07	1.77
+++ LVM2/lib/config/config.c	2010/04/01 10:34:09	1.78
@@ -911,9 +911,9 @@
 				if (!cn_found)
 					cn_found = cn;
 				else
-					log_error("WARNING: Ignoring duplicate"
-						  " config node: %s ("
-						  "seeking %s)", cn->key, path);
+					log_warn("WARNING: Ignoring duplicate"
+						 " config node: %s ("
+						 "seeking %s)", cn->key, path);
 			}
 
 			cn = cn->sib;
--- LVM2/lib/device/dev-io.c	2009/05/20 11:09:49	1.65
+++ LVM2/lib/device/dev-io.c	2010/04/01 10:34:10	1.66
@@ -383,8 +383,8 @@
 
 		if (dev->open_count && !need_excl) {
 			/* FIXME Ensure we never get here */
-			log_debug("WARNING: %s already opened read-only",
-				  dev_name(dev));
+			log_error(INTERNAL_ERROR "%s already opened read-only",
+				 dev_name(dev));
 			dev->open_count++;
 		}
 
@@ -392,8 +392,8 @@
 	}
 
 	if (memlock())
-		log_error("WARNING: dev_open(%s) called while suspended",
-			  dev_name(dev));
+		log_error(INTERNAL_ERROR "dev_open(%s) called while suspended",
+			 dev_name(dev));
 
 	if (dev->flags & DEV_REGULAR)
 		name = dev_name(dev);
--- LVM2/lib/format1/import-export.c	2009/09/28 17:46:16	1.110
+++ LVM2/lib/format1/import-export.c	2010/04/01 10:34:10	1.111
@@ -110,9 +110,9 @@
 			size = pv->pe_count * (uint64_t) vg->extent_size +
 			       pv->pe_start;
 			if (size > pv->size)
-				log_error("WARNING: Physical Volume %s is too "
-					  "large for underlying device",
-					  pv_dev_name(pv));
+				log_warn("WARNING: Physical Volume %s is too "
+					 "large for underlying device",
+					 pv_dev_name(pv));
 		}
 	}
 
--- LVM2/lib/format_text/import_vsn1.c	2010/03/31 17:20:03	1.70
+++ LVM2/lib/format_text/import_vsn1.c	2010/04/01 10:34:10	1.71
@@ -264,9 +264,9 @@
 			size = pv->pe_count * (uint64_t) vg->extent_size +
 			       pv->pe_start;
 			if (size > pv->size)
-				log_error("WARNING: Physical Volume %s is too "
-					  "large for underlying device",
-					  pv_dev_name(pv));
+				log_warn("WARNING: Physical Volume %s is too "
+					 "large for underlying device",
+					 pv_dev_name(pv));
 		}
 	}
 
--- LVM2/lib/locking/locking.c	2010/03/31 17:23:57	1.76
+++ LVM2/lib/locking/locking.c	2010/04/01 10:34:10	1.77
@@ -293,8 +293,7 @@
 	    find_config_tree_int(cmd, "locking/fallback_to_local_locking",
 	    	    find_config_tree_int(cmd, "global/fallback_to_local_locking",
 					 DEFAULT_FALLBACK_TO_LOCAL_LOCKING))) {
-		log_warn_suppress(suppress_messages,
-				  "WARNING: Falling back to local file-based locking.");
+		log_warn_suppress(suppress_messages, "WARNING: Falling back to local file-based locking.");
 		log_warn_suppress(suppress_messages,
 				  "Volume Groups with the clustered attribute will "
 				  "be inaccessible.");
--- LVM2/lib/metadata/lv_manip.c	2010/03/31 20:26:04	1.220
+++ LVM2/lib/metadata/lv_manip.c	2010/04/01 10:34:10	1.221
@@ -3172,7 +3172,7 @@
 	}
 
 	if (!lp->zero && !lp->snapshot)
-		log_error("WARNING: \"%s\" not zeroed", lv->name);
+		log_warn("WARNING: \"%s\" not zeroed", lv->name);
 	else if (!set_lv(cmd, lv, UINT64_C(0), 0)) {
 		log_error("Aborting. Failed to wipe %s.",
 			  lp->snapshot ? "snapshot exception store" :
--- LVM2/tools/pvscan.c	2009/12/11 13:16:39	1.49
+++ LVM2/tools/pvscan.c	2010/04/01 10:34:11	1.50
@@ -152,7 +152,7 @@
 		/* Also check for MD use? */
 /*******
 		if (MAJOR(pv_create_kdev_t(pv[p]->pv_name)) != MD_MAJOR) {
-			log_print
+			log_warn
 			    ("WARNING: physical volume \"%s\" belongs to a meta device",
 			     pv[p]->pv_name);
 		}


