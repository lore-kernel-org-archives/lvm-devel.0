From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Sep 2009 22:47:55 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/loc ...
Message-ID: <20090914224755.28648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-14 22:47:50

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c no_locking.c 
	tools          : dumpconfig.c lvchange.c lvconvert.c lvcreate.c 
	                 lvmcmdline.c lvremove.c lvrename.c polldaemon.c 
	                 pvchange.c pvcreate.c pvresize.c pvscan.c 
	                 reporter.c toollib.c vgcfgbackup.c 
	                 vgcfgrestore.c vgchange.c vgck.c vgconvert.c 
	                 vgcreate.c vgdisplay.c vgexport.c vgextend.c 
	                 vgimport.c vgmerge.c vgmknodes.c vgreduce.c 
	                 vgremove.c vgrename.c vgscan.c vgsplit.c 

Log message:
	Add lots of missing stack debug messages to tools.
	Make readonly locking available as locking type 4.
	Fix readonly locking to permit writeable global locks (for vgscan). (2.02.49)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1259&r2=1.1260
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.207&r2=1.208
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgexport.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgimport.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmknodes.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2009/09/11 16:06:31	1.1259
+++ LVM2/WHATS_NEW	2009/09/14 22:47:49	1.1260
@@ -1,5 +1,8 @@
 Version 2.02.52 -
 =================================
+  Add lots of missing stack debug messages to tools.
+  Make readonly locking available as locking type 4.
+  Fix readonly locking to permit writeable global locks (for vgscan). (2.02.49)
   Add manpage entry for dmsetup's udevcomplete_all and udevcookies commands.
   Add DM_UDEV_RULES_VSN udev enviroment variable.
   Check that udev is running and set internal state appropriately.
@@ -97,6 +100,7 @@
 
 Version 2.02.49 - 15th July 2009
 ================================
+  Add readonly locking type to replace implementation of --ignorelockingfailure.
   Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again.
   Add unit test case for liblvm VG create/delete APIs.
   Add liblvm APIs to implement creation and deletion of VGs.
--- LVM2/lib/locking/locking.c	2009/09/02 21:34:11	1.65
+++ LVM2/lib/locking/locking.c	2009/09/14 22:47:49	1.66
@@ -261,6 +261,13 @@
 		return 1;
 #endif
 
+	case 4:
+		log_verbose("Read-only locking selected. "
+			    "Only read operations permitted.");
+		if (!init_readonly_locking(&_locking, cmd))
+			break;
+		return 1;
+
 	default:
 		log_error("Unknown locking type requested.");
 		return 0;
@@ -280,7 +287,6 @@
 	if (!ignorelockingfailure())
 		return 0;
 
-	/* FIXME Ensure only read ops are permitted */
 	log_verbose("Locking disabled - only read operations permitted.");
 	init_readonly_locking(&_locking, cmd);
 
--- LVM2/lib/locking/no_locking.c	2009/08/02 21:03:09	1.18
+++ LVM2/lib/locking/no_locking.c	2009/09/14 22:47:49	1.19
@@ -71,10 +71,13 @@
 				   uint32_t flags)
 {
 	if ((flags & LCK_TYPE_MASK) == LCK_WRITE &&
-	    (flags & LCK_SCOPE_MASK) == LCK_VG) {
+	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
+	    !(flags & LCK_CACHE) &&
+	    strcmp(resource, VG_GLOBAL)) {
 		log_error("Write locks are prohibited with --ignorelockingfailure.");
 		return 0;
 	}
+
 	return _no_lock_resource(cmd, resource, flags);
 }
 
--- LVM2/tools/dumpconfig.c	2008/01/30 14:00:01	1.7
+++ LVM2/tools/dumpconfig.c	2009/09/14 22:47:49	1.8
@@ -22,8 +22,10 @@
 	if (arg_count(cmd, file_ARG))
 		file = arg_str_value(cmd, file_ARG, "");
 
-	if (!write_config_file(cmd->cft, file, argc, argv))
+	if (!write_config_file(cmd->cft, file, argc, argv)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/lvchange.c	2009/08/13 14:27:33	1.109
+++ LVM2/tools/lvchange.c	2009/09/14 22:47:49	1.110
@@ -591,8 +591,10 @@
 
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
-		if (!archive(lv->vg))
+		if (!archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		archived = 1;
 		doit += lvchange_permission(cmd, lv);
 		docmds++;
@@ -600,8 +602,10 @@
 
 	/* allocation policy change */
 	if (arg_count(cmd, contiguous_ARG) || arg_count(cmd, alloc_ARG)) {
-		if (!archived && !archive(lv->vg))
+		if (!archived && !archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		archived = 1;
 		doit += lvchange_alloc(cmd, lv);
 		docmds++;
@@ -609,8 +613,10 @@
 
 	/* read ahead sector change */
 	if (arg_count(cmd, readahead_ARG)) {
-		if (!archived && !archive(lv->vg))
+		if (!archived && !archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		archived = 1;
 		doit += lvchange_readahead(cmd, lv);
 		docmds++;
@@ -618,19 +624,25 @@
 
 	/* read ahead sector change */
 	if (arg_count(cmd, persistent_ARG)) {
-		if (!archived && !archive(lv->vg))
+		if (!archived && !archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		archived = 1;
 		doit += lvchange_persistent(cmd, lv);
 		docmds++;
-		if (sigint_caught())
+		if (sigint_caught()) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
 	/* add tag */
 	if (arg_count(cmd, addtag_ARG)) {
-		if (!archived && !archive(lv->vg))
+		if (!archived && !archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		archived = 1;
 		doit += lvchange_tag(cmd, lv, addtag_ARG);
 		docmds++;
@@ -638,8 +650,10 @@
 
 	/* del tag */
 	if (arg_count(cmd, deltag_ARG)) {
-		if (!archived && !archive(lv->vg))
+		if (!archived && !archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		archived = 1;
 		doit += lvchange_tag(cmd, lv, deltag_ARG);
 		docmds++;
@@ -649,28 +663,38 @@
 		log_print("Logical volume \"%s\" changed", lv->name);
 
 	if (arg_count(cmd, resync_ARG))
-		if (!lvchange_resync(cmd, lv))
+		if (!lvchange_resync(cmd, lv)) {
+			stack;
 			return ECMD_FAILED;
+		}
 
 	/* availability change */
 	if (arg_count(cmd, available_ARG)) {
-		if (!lvchange_availability(cmd, lv))
+		if (!lvchange_availability(cmd, lv)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
 	if (arg_count(cmd, refresh_ARG))
-		if (!lvchange_refresh(cmd, lv))
+		if (!lvchange_refresh(cmd, lv)) {
+			stack;
 			return ECMD_FAILED;
+		}
 
 	if (!arg_count(cmd, available_ARG) &&
 	    !arg_count(cmd, refresh_ARG) &&
 	    arg_count(cmd, monitor_ARG)) {
-		if (!lvchange_monitoring(cmd, lv))
+		if (!lvchange_monitoring(cmd, lv)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
-	if (doit != docmds)
+	if (doit != docmds) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/lvconvert.c	2009/08/02 21:59:21	1.91
+++ LVM2/tools/lvconvert.c	2009/09/14 22:47:49	1.92
@@ -904,15 +904,23 @@
 			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 			return ECMD_FAILED;
 		}
-		if (!archive(lv->vg))
+		if (!archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
-		if (!lvconvert_snapshot(cmd, lv, lp))
+		}
+		if (!lvconvert_snapshot(cmd, lv, lp)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	} else if (arg_count(cmd, mirrors_ARG) || (lv->status & MIRRORED)) {
-		if (!archive(lv->vg))
+		if (!archive(lv->vg)) {
+			stack;
 			return ECMD_FAILED;
-		if (!_lvconvert_mirrors(cmd, lv, lp))
+		}
+		if (!_lvconvert_mirrors(cmd, lv, lp)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
 	return ECMD_PROCESSED;
--- LVM2/tools/lvcreate.c	2009/07/26 02:34:09	1.207
+++ LVM2/tools/lvcreate.c	2009/09/14 22:47:49	1.208
@@ -586,14 +586,19 @@
 	vg = vg_read_for_update(cmd, lp.vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
+		stack;
 		return ECMD_FAILED;
 	}
 
-	if (!_update_extents_params(vg, &lp, &lcp))
+	if (!_update_extents_params(vg, &lp, &lcp)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!lv_create_single(vg, &lp))
+	if (!lv_create_single(vg, &lp)) {
+		stack;
 		r = ECMD_FAILED;
+	}
 
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;
--- LVM2/tools/lvmcmdline.c	2009/08/04 15:36:15	1.105
+++ LVM2/tools/lvmcmdline.c	2009/09/14 22:47:49	1.106
@@ -963,8 +963,10 @@
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
-	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))
+	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv))) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	log_debug("Parsing: %s", cmd->cmd_line);
 
--- LVM2/tools/lvremove.c	2009/07/01 17:00:52	1.58
+++ LVM2/tools/lvremove.c	2009/09/14 22:47:49	1.59
@@ -26,8 +26,10 @@
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
-	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG)))
+	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG))) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/lvrename.c	2009/07/07 01:18:35	1.55
+++ LVM2/tools/lvrename.c	2009/09/14 22:47:49	1.56
@@ -105,6 +105,7 @@
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
+		stack;
 		return ECMD_FAILED;
 	}
 
--- LVM2/tools/polldaemon.c	2009/07/07 01:18:35	1.21
+++ LVM2/tools/polldaemon.c	2009/09/14 22:47:49	1.22
@@ -185,8 +185,10 @@
 	const char *name;
 	int finished;
 
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv_mirr = lvl->lv;
@@ -253,8 +255,10 @@
 	}
 
 	if (name) {
-		if (!_wait_for_single_mirror(cmd, name, uuid, &parms))
+		if (!_wait_for_single_mirror(cmd, name, uuid, &parms)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	} else
 		_poll_for_all_vgs(cmd, &parms);
 
--- LVM2/tools/pvchange.c	2009/07/08 18:15:51	1.72
+++ LVM2/tools/pvchange.c	2009/09/14 22:47:49	1.73
@@ -274,6 +274,7 @@
 	} else {
 		log_verbose("Scanning for physical volume names");
 		if (!(pvslist = get_pvs(cmd))) {
+			stack;
 			return ECMD_FAILED;
 		}
 
--- LVM2/tools/pvcreate.c	2009/07/30 17:45:30	1.84
+++ LVM2/tools/pvcreate.c	2009/09/14 22:47:49	1.85
@@ -195,8 +195,10 @@
 			return ECMD_FAILED;
 		}
 
-		if (!pvcreate_single(cmd, argv[i], &pp))
+		if (!pvcreate_single(cmd, argv[i], &pp)) {
+			stack;
 			ret = ECMD_FAILED;
+		}
 
 		unlock_vg(cmd, VG_ORPHANS);
 		if (sigint_caught())
--- LVM2/tools/pvresize.c	2009/07/15 05:50:22	1.32
+++ LVM2/tools/pvresize.c	2009/09/14 22:47:49	1.33
@@ -176,8 +176,10 @@
 
 	params->total++;
 
-	if (!_pv_resize_single(cmd, vg, pv, params->new_size))
+	if (!_pv_resize_single(cmd, vg, pv, params->new_size)) {
+		stack;
 		return ECMD_FAILED;
+	}
 	
 	params->done++;
 
--- LVM2/tools/pvscan.c	2008/11/03 22:14:30	1.47
+++ LVM2/tools/pvscan.c	2009/09/14 22:47:49	1.48
@@ -135,6 +135,7 @@
 	log_verbose("Walking through all physical volumes");
 	if (!(pvslist = get_pvs(cmd))) {
 		unlock_vg(cmd, VG_GLOBAL);
+		stack;
 		return ECMD_FAILED;
 	}
 
--- LVM2/tools/reporter.c	2009/07/15 05:50:22	1.54
+++ LVM2/tools/reporter.c	2009/09/14 22:47:49	1.55
@@ -20,11 +20,15 @@
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
 {
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	check_current_backup(vg);
 
@@ -37,8 +41,10 @@
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
@@ -46,8 +52,10 @@
 static int _segs_single(struct cmd_context *cmd __attribute((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
@@ -102,8 +110,10 @@
 	dm_list_init(&_free_logical_volume.snapshot_segs);
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg))
+			   seg ? : &_free_lv_segment, pvseg)) {
+		stack;
 		ret = ECMD_FAILED;
+	}
 
 	return ret;
 }
@@ -155,8 +165,10 @@
 		 pv = pvl->pv;
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {
+		stack;
 		ret = ECMD_FAILED;
+	}
 
 out:
 	if (vg_name)
@@ -171,8 +183,10 @@
 static int _label_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv, void *handle)
 {
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
@@ -181,8 +195,10 @@
 		      struct volume_group *vg,
 		      void *handle)
 {
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvs_single);
 }
@@ -191,8 +207,10 @@
 			 struct volume_group *vg,
 			 void *handle)
 {
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return process_each_pv_in_vg(cmd, vg, NULL, handle, &_pvsegs_single);
 }
--- LVM2/tools/toollib.c	2009/08/24 11:37:21	1.167
+++ LVM2/tools/toollib.c	2009/09/14 22:47:49	1.168
@@ -293,7 +293,8 @@
 			if (ret_max < ECMD_FAILED) {
 				log_error("Skipping volume group %s", vgname);
 				ret_max = ECMD_FAILED;
-			}
+			} else
+				stack;
 			continue;
 		}
 
@@ -431,9 +432,10 @@
 	log_verbose("Finding volume group \"%s\"", vg_name);
 
 	vg = vg_read(cmd, vg_name, vgid, flags);
-	if (vg_read_error(vg) == FAILED_ALLOCATION ||
-	    vg_read_error(vg) == FAILED_NOTFOUND) {
+	/* Allow FAILED_INCONSISTENT through only for vgcfgrestore */
+	if (vg_read_error(vg) && (vg_read_error(vg) != FAILED_INCONSISTENT)) {
 		vg_release(vg);
+		stack;
 		return ECMD_FAILED;
 	}
 
@@ -445,9 +447,8 @@
 	}
 
 	if ((ret = process_single(cmd, vg_name, vg,
-				  handle)) > ret_max) {
+				  handle)) > ret_max)
 		ret_max = ret;
-	}
 
 out:
 	unlock_and_release_vg(cmd, vg, vg_name);
@@ -728,6 +729,7 @@
 				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
 					vg_release(vg);
+					stack;
 					continue;
 				}
 
--- LVM2/tools/vgcfgbackup.c	2009/07/15 03:30:04	1.29
+++ LVM2/tools/vgcfgbackup.c	2009/09/14 22:47:49	1.30
@@ -54,9 +54,6 @@
 	char **last_filename = (char **)handle;
 	char *filename;
 
-	if (vg_read_error(vg) && (vg_read_error(vg) != FAILED_INCONSISTENT))
-		return ECMD_FAILED;
-
 	if (arg_count(cmd, file_ARG)) {
 		if (!(filename = _expand_filename(arg_value(cmd, file_ARG),
 						  vg->name, last_filename))) {
@@ -64,8 +61,10 @@
 			return ECMD_FAILED;
 		}
 
-		if (!backup_to_file(filename, vg->cmd->cmd_line, vg))
+		if (!backup_to_file(filename, vg->cmd->cmd_line, vg)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	} else {
 		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
 			log_error("No backup taken: specify filename with -f "
--- LVM2/tools/vgcfgrestore.c	2009/08/13 17:16:39	1.22
+++ LVM2/tools/vgcfgrestore.c	2009/09/14 22:47:50	1.23
@@ -36,10 +36,12 @@
 	 */
 	if (arg_count(cmd, list_ARG)) {
 		if (!(arg_count(cmd,file_ARG) ?
-			archive_display_file(cmd,
-					arg_str_value(cmd, file_ARG, "")) :
-			archive_display(cmd, vg_name)))
+			    archive_display_file(cmd,
+				arg_str_value(cmd, file_ARG, "")) :
+			    archive_display(cmd, vg_name))) {
+			stack;
 			return ECMD_FAILED;
+		}
 		return ECMD_PROCESSED;
 	}
 
--- LVM2/tools/vgchange.c	2009/09/14 19:44:16	1.83
+++ LVM2/tools/vgchange.c	2009/09/14 22:47:50	1.84
@@ -179,8 +179,10 @@
 
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	/* FIXME: make consistent with vg_set_alloc_policy() */
 	if (alloc == vg->alloc) {
@@ -188,11 +190,15 @@
 			  get_alloc_string(vg->alloc));
 		return ECMD_FAILED;
 	}
-	if (!vg_set_alloc_policy(vg, alloc))
+	if (!vg_set_alloc_policy(vg, alloc)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -218,16 +224,20 @@
 		return ECMD_FAILED;
 	}
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (resizeable)
 		vg->status |= RESIZEABLE_VG;
 	else
 		vg->status &= ~RESIZEABLE_VG;
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -265,16 +275,20 @@
 		}
 	}
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (clustered)
 		vg->status |= CLUSTERED;
 	else
 		vg->status &= ~CLUSTERED;
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -288,14 +302,20 @@
 {
 	uint32_t max_lv = arg_uint_value(cmd, logicalvolume_ARG, 0);
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_set_max_lv(vg, max_lv))
+	if (!vg_set_max_lv(vg, max_lv)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -314,14 +334,20 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_set_max_pv(vg, max_pv))
+	if (!vg_set_max_pv(vg, max_pv)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -347,16 +373,20 @@
 		return ECMD_PROCESSED;
 	}
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (!vg_set_extent_size(vg, extent_size)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -380,8 +410,10 @@
 		return ECMD_FAILED;
 	}
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if ((arg == addtag_ARG)) {
 		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
@@ -397,8 +429,10 @@
 		}
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -417,8 +451,10 @@
 		return ECMD_FAILED;
 	}
 
-	if (!archive(vg))
+	if (!archive(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (!id_create(&vg->id)) {
 		log_error("Failed to generate new random UUID for VG %s.",
@@ -430,8 +466,10 @@
 		memcpy(&lvl->lv->lvid, &vg->id, sizeof(vg->id));
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	backup(vg);
 
@@ -444,8 +482,10 @@
 {
 	log_verbose("Refreshing volume group \"%s\"", vg->name);
 
-	if (!vg_refresh_visible(cmd, vg))
+	if (!vg_refresh_visible(cmd, vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
@@ -456,8 +496,10 @@
 {
 	int r = ECMD_FAILED;
 
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
--- LVM2/tools/vgck.c	2009/07/14 19:37:18	1.23
+++ LVM2/tools/vgck.c	2009/09/14 22:47:50	1.24
@@ -21,14 +21,20 @@
 		       struct volume_group *vg,
 		       void *handle __attribute((unused)))
 {
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_check_status(vg, EXPORTED_VG))
+	if (!vg_check_status(vg, EXPORTED_VG)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_validate(vg))
+	if (!vg_validate(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgconvert.c	2009/09/02 21:39:07	1.38
+++ LVM2/tools/vgconvert.c	2009/09/14 22:47:50	1.39
@@ -32,11 +32,15 @@
 	struct lvinfo info;
 	int active = 0;
 
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG))
+	if (!vg_check_status(vg, LVM_WRITE | EXPORTED_VG)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	if (vg->fid->fmt == cmd->fmt) {
 		log_error("Volume group \"%s\" already uses format %s",
@@ -111,8 +115,10 @@
 		}
 	}
 
-	if (active)
+	if (active) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		existing_pv = pvl->pv;
--- LVM2/tools/vgcreate.c	2009/07/24 15:01:44	1.65
+++ LVM2/tools/vgcreate.c	2009/09/14 22:47:50	1.66
@@ -102,14 +102,12 @@
 			clustered_message = "Non-clustered ";
 	}
 
-	if (!archive(vg)) {
-		goto bad;
-	}
+	if (!archive(vg))
+		goto_bad;
 
 	/* Store VG on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		goto bad;
-	}
+	if (!vg_write(vg) || !vg_commit(vg))
+		goto_bad;
 
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vp_new.vg_name);
--- LVM2/tools/vgdisplay.c	2009/07/01 17:00:52	1.24
+++ LVM2/tools/vgdisplay.c	2009/09/14 22:47:50	1.25
@@ -20,8 +20,10 @@
 			    void *handle __attribute((unused)))
 {
 	/* FIXME Do the active check here if activevolumegroups_ARG ? */
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	vg_check_status(vg, EXPORTED_VG);
 
--- LVM2/tools/vgexport.c	2009/07/01 17:00:52	1.21
+++ LVM2/tools/vgexport.c	2009/09/14 22:47:50	1.22
@@ -24,16 +24,16 @@
 	struct physical_volume *pv;
 
 	if (vg_read_error(vg))
-		goto error;
+		goto_bad;
 
 	if (lvs_in_vg_activated(vg)) {
 		log_error("Volume group \"%s\" has active logical volumes",
 			  vg_name);
-		goto error;
+		goto bad;
 	}
 
 	if (!archive(vg))
-		goto error;
+		goto_bad;
 
 	vg->status |= EXPORTED_VG;
 
@@ -43,7 +43,7 @@
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg))
-		goto error;
+		goto_bad;
 
 	backup(vg);
 
@@ -51,7 +51,7 @@
 
 	return ECMD_PROCESSED;
 
-      error:
+bad:
 	return ECMD_FAILED;
 }
 
--- LVM2/tools/vgextend.c	2009/08/13 12:03:46	1.49
+++ LVM2/tools/vgextend.c	2009/09/14 22:47:50	1.50
@@ -40,6 +40,7 @@
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {
 		vg_release(vg);
+		stack;
 		return ECMD_FAILED;
 	}
 
@@ -50,11 +51,11 @@
 	}
 
 	if (!archive(vg))
-		goto error;
+		goto_bad;
 
 	/* extend vg */
 	if (!vg_extend(vg, argc, argv))
-		goto error;
+		goto_bad;
 
 	/* ret > 0 */
 	log_verbose("Volume group \"%s\" will be extended by %d new "
@@ -62,13 +63,13 @@
 
 	/* store vg on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
-		goto error;
+		goto_bad;
 
 	backup(vg);
 	log_print("Volume group \"%s\" successfully extended", vg_name);
 	r = ECMD_PROCESSED;
 
-error:
+bad:
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
--- LVM2/tools/vgimport.c	2009/09/14 19:44:16	1.21
+++ LVM2/tools/vgimport.c	2009/09/14 22:47:50	1.22
@@ -24,20 +24,20 @@
 	struct physical_volume *pv;
 
 	if (vg_read_error(vg))
-		goto error;
+		goto_bad;
 
 	if (!vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is not exported", vg_name);
-		goto error;
+		goto bad;
 	}
 
 	if (vg_status(vg) & PARTIAL_VG) {
 		log_error("Volume group \"%s\" is partially missing", vg_name);
-		goto error;
+		goto bad;
 	}
 
 	if (!archive(vg))
-		goto error;
+		goto_bad;
 
 	vg->status &= ~EXPORTED_VG;
 
@@ -47,7 +47,7 @@
 	}
 
 	if (!vg_write(vg) || !vg_commit(vg))
-		goto error;
+		goto_bad;
 
 	backup(vg);
 
@@ -55,7 +55,7 @@
 
 	return ECMD_PROCESSED;
 
-      error:
+bad:
 	return ECMD_FAILED;
 }
 
--- LVM2/tools/vgmerge.c	2009/09/02 21:28:43	1.64
+++ LVM2/tools/vgmerge.c	2009/09/14 22:47:50	1.65
@@ -46,20 +46,26 @@
 
 	if (lock_vg_from_first) {
 		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
-		if (!vg_from)
+		if (!vg_from) {
+			stack;
 			return ECMD_FAILED;
+		}
 		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
 		if (!vg_to) {
+			stack;
 			unlock_and_release_vg(cmd, vg_from, vg_name_from);
 			return ECMD_FAILED;
 		}
 	} else {
 		vg_to = _vgmerge_vg_read(cmd, vg_name_to);
-		if (!vg_to)
+		if (!vg_to) {
+			stack;
 			return ECMD_FAILED;
+		}
 
 		vg_from = _vgmerge_vg_read(cmd, vg_name_from);
 		if (!vg_from) {
+			stack;
 			unlock_and_release_vg(cmd, vg_to, vg_name_to);
 			return ECMD_FAILED;
 		}
--- LVM2/tools/vgmknodes.c	2008/12/22 09:00:51	1.7
+++ LVM2/tools/vgmknodes.c	2009/09/14 22:47:50	1.8
@@ -19,19 +19,25 @@
 			     void *handle __attribute((unused)))
 {
 	if (arg_count(cmd, refresh_ARG) && lv_is_visible(lv))
-		if (!lv_refresh(cmd, lv))
+		if (!lv_refresh(cmd, lv)) {
+			stack;
 			return ECMD_FAILED;
+		}
 
-	if (!lv_mknodes(cmd, lv))
+	if (!lv_mknodes(cmd, lv)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
 
 int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!lv_mknodes(cmd, NULL))
+	if (!lv_mknodes(cmd, NULL)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
 			    &_vgmknodes_single);
--- LVM2/tools/vgreduce.c	2009/07/24 11:13:36	1.97
+++ LVM2/tools/vgreduce.c	2009/09/14 22:47:50	1.98
@@ -404,7 +404,7 @@
 	pvl = find_pv_in_vg(vg, name);
 
 	if (!archive(vg))
-		goto bad;
+		goto_bad;
 
 	log_verbose("Removing \"%s\" from volume group \"%s\"", name, vg->name);
 
@@ -512,12 +512,12 @@
 	vg = vg_read_for_update(cmd, vg_name, NULL, READ_ALLOW_EXPORTED);
 	if (vg_read_error(vg) == FAILED_ALLOCATION ||
 	    vg_read_error(vg) == FAILED_NOTFOUND)
-		goto out;
+		goto_out;
 
 	/* FIXME We want to allow read-only VGs to be changed here? */
 	if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
 	    && !arg_count(cmd, removemissing_ARG))
-		goto out;
+		goto_out;
 
 	if (repairing) {
 		if (!vg_read_error(vg) && !vg_missing_pv_count(vg)) {
@@ -536,14 +536,14 @@
 
 		if (vg_read_error(vg) && vg_read_error(vg) != FAILED_READ_ONLY
 		    && vg_read_error(vg) != FAILED_INCONSISTENT)
-			goto out;
+			goto_out;
 
 		if (!archive(vg))
-			goto out;
+			goto_out;
 
 		if (arg_count(cmd, force_ARG)) {
 			if (!_make_vg_consistent(cmd, vg))
-				goto out;
+				goto_out;
 		} else
 			fixed = _consolidate_vg(cmd, vg);
 
@@ -563,7 +563,7 @@
 
 	} else {
 		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG))
-			goto out;
+			goto_out;
 
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch here? */
--- LVM2/tools/vgremove.c	2009/09/02 21:39:29	1.55
+++ LVM2/tools/vgremove.c	2009/09/14 22:47:50	1.56
@@ -22,11 +22,15 @@
 	unsigned lv_count;
 	force_t force;
 
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_check_status(vg, EXPORTED_VG))
+	if (!vg_check_status(vg, EXPORTED_VG)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	lv_count = vg_visible_lvs(vg);
 
@@ -40,15 +44,21 @@
 			log_print("Volume group \"%s\" not removed", vg_name);
 			return ECMD_FAILED;
 		}
-		if (!remove_lvs_in_vg(cmd, vg, force))
+		if (!remove_lvs_in_vg(cmd, vg, force)) {
+			stack;
 			return ECMD_FAILED;
+		}
 	}
 
-	if (!vg_remove_check(vg))
+	if (!vg_remove_check(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
-	if (!vg_remove(vg))
+	if (!vg_remove(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgrename.c	2009/09/02 21:29:40	1.67
+++ LVM2/tools/vgrename.c	2009/09/14 22:47:50	1.68
@@ -206,8 +206,10 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!vg_rename_path(cmd, argv[0], argv[1]))
+	if (!vg_rename_path(cmd, argv[0], argv[1])) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgscan.c	2009/09/14 19:44:16	1.35
+++ LVM2/tools/vgscan.c	2009/09/14 22:47:50	1.36
@@ -19,8 +19,10 @@
 			 struct volume_group *vg,
 			 void *handle __attribute((unused)))
 {
-	if (vg_read_error(vg))
+	if (vg_read_error(vg)) {
+		stack;
 		return ECMD_FAILED;
+	}
 
 	log_print("Found %svolume group \"%s\" using metadata type %s",
 		  vg_is_exported(vg) ? "exported " : "", vg_name,
--- LVM2/tools/vgsplit.c	2009/09/02 21:27:39	1.93
+++ LVM2/tools/vgsplit.c	2009/09/14 22:47:50	1.94
@@ -319,8 +319,10 @@
 
 	if (lock_vg_from_first) {
 		vg_from = _vgsplit_from(cmd, vg_name_from);
-		if (!vg_from)
+		if (!vg_from) {
+			stack;
 			return ECMD_FAILED;
+		}
 		/*
 		 * Set metadata format of original VG.
 		 * NOTE: We must set the format before calling vg_create()
@@ -331,15 +333,19 @@
 		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
 		if (!vg_to) {
 			unlock_and_release_vg(cmd, vg_from, vg_name_from);
+			stack;
 			return ECMD_FAILED;
 		}
 	} else {
 		vg_to = _vgsplit_to(cmd, vg_name_to, &existing_vg);
-		if (!vg_to)
+		if (!vg_to) {
+			stack;
 			return ECMD_FAILED;
+		}
 		vg_from = _vgsplit_from(cmd, vg_name_from);
 		if (!vg_from) {
 			unlock_and_release_vg(cmd, vg_to, vg_name_to);
+			stack;
 			return ECMD_FAILED;
 		}
 
@@ -355,7 +361,7 @@
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
-			goto_bad;
+			goto bad;
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
@@ -369,12 +375,12 @@
 
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;
-			goto bad;
+			goto_bad;
 		}
 
 		if (validate_vg_create_params(cmd, &vp_new)) {
 			r = EINVALID_CMD_LINE;
-			goto bad;
+			goto_bad;
 		}
 
 		if (!vg_set_extent_size(vg_to, vp_new.extent_size) ||
@@ -416,7 +422,7 @@
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");
-		goto_bad;
+		goto bad;
 	}
 
 	/* Set proper name for all PVs in new VG */
@@ -465,7 +471,7 @@
 		if (vg_read_error(vg_to)) {
 			log_error("Volume group \"%s\" became inconsistent: "
 				  "please fix manually", vg_name_to);
-			goto_bad;
+			goto bad;
 		}
 	}
 


