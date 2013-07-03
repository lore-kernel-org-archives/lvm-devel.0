From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Jul 2013 12:48:59 +0000 (UTC)
Subject: master - sigint: improve logic on for sigint reaction
Message-ID: <20130703124859.682B960CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f335ffa35552ed9d002d8a6884c707b2942750c
Commit:        6f335ffa35552ed9d002d8a6884c707b2942750c
Parent:        ffa11ed35688243a4546d4a35a97fc0339916651
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 1 16:30:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 3 14:46:42 2013 +0200

sigint: improve logic on for sigint reaction

Fix and improve handling on sigint.

Always check for signal presence *before* calling of command,
so it will not call the command when break was hit.

If the command has been finished succesfully there is
no problem to mark the command ok and not report interrupt at all.

Fix cuple related stack; reports and assignments.
---
 WHATS_NEW               |    1 +
 lib/cache/lvmetad.c     |    8 ++-
 lib/locking/locking.c   |    3 +
 lib/metadata/lv_manip.c |    2 +-
 tools/lvchange.c        |    4 +-
 tools/pvcreate.c        |    6 +-
 tools/pvscan.c          |   18 +++++--
 tools/toollib.c         |  126 ++++++++++++++++++++++++-----------------------
 8 files changed, 91 insertions(+), 77 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f1f9a82..adecd63 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Improve error loging when user tries to interrupt commands.
   Rename _swap_lv to _swap_lv_identifiers and move to allow an additional user.
   Rename snapshot segment returning methods from find_*_cow to find_*_snapshot.
   liblvm/python API: Additions: PV create/removal/resize/listing
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a107047..f43283f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -955,11 +955,13 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	init_silent(1);
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!lvmetad_pvscan_single(cmd, dev, handler))
+		if (sigint_caught()) {
 			r = 0;
-
-		if (sigint_caught())
+			stack;
 			break;
+		}
+		if (!lvmetad_pvscan_single(cmd, dev, handler))
+			r = 0;
 	}
 
 	init_silent(was_silent);
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index cdd6ac4..34e8bd9 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -54,6 +54,9 @@ static void _catch_sigint(int unused __attribute__((unused)))
 }
 
 int sigint_caught(void) {
+	if (_sigint_caught)
+		log_error("Interrupted...");
+
 	return _sigint_caught;
 }
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4c3beb0..b7914dd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3252,7 +3252,7 @@ static int _request_confirmation(struct cmd_context *cmd,
 			return 0;
 		}
 		if (sigint_caught())
-			return 0;
+			return_0;
 	}
 
 	return 1;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4b88a51..f7ce7fd 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -347,7 +347,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 			}
 
 			if (sigint_caught())
-				return 0;
+				return_0;
 
 			active = 1;
 		}
@@ -643,7 +643,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 		}
 
 		if (sigint_caught())
-			return 0;
+			return_0;
 
 		log_verbose("Ensuring %s is inactive.", lv->name);
 		if (!deactivate_lv(cmd, lv)) {
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index d2de4d9..b18e400 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -108,14 +108,14 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	for (i = 0; i < argc; i++) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
 		if (ECMD_PROCESSED != pvcreate_locked(cmd, argv[i], &pp)) {
 			ret = ECMD_FAILED;
 		}
-
-		if (sigint_caught())
-			return ret;
 	}
 
 	return ret;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 665e416..63dc524 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -193,13 +193,16 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			ret = ECMD_FAILED;
 			continue;
 		}
-
-		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
+		if (sigint_caught()) {
 			ret = ECMD_FAILED;
+			stack;
 			break;
 		}
-		if (sigint_caught())
+		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
+			ret = ECMD_FAILED;
+			stack;
 			break;
+		}
 	}
 
 	if (!devno_args)
@@ -232,14 +235,17 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 				dm_free(buf);
 			continue;
 		}
-
+		if (sigint_caught()) {
+			ret = ECMD_FAILED;
+			stack;
+			break;
+		}
 		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
 			ret = ECMD_FAILED;
+			stack;
 			break;
 		}
 
-		if (sigint_caught())
-			break;
 	}
 
 out:
diff --git a/tools/toollib.c b/tools/toollib.c
index 6e23e17..1a6fbee 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -161,6 +161,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (!process_lv)
 			continue;
 
+		if (sigint_caught())
+			return_ECMD_FAILED;
+
 		lvl->lv->vg->cmd_missing_vgs = 0;
 		ret = process_single_lv(cmd, lvl->lv, handle);
 		if (ret != ECMD_PROCESSED && failed_lvnames) {
@@ -175,10 +178,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		}
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught()) {
-			stack;
-			return ret_max;
-		}
 	}
 
 	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
@@ -357,7 +356,10 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			}
 		}
 
-		while (!sigint_caught()) {
+		for (;;) {
+			if (sigint_caught())
+				return_ECMD_FAILED;
+
 			ret = process_each_lv_in_vg(cmd, cvl_vg->vg, &lvnames,
 						    tags_arg, &failed_lvnames,
 						    handle, process_single_lv);
@@ -384,11 +386,6 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 			ret_max = ret;
 
 		free_cmd_vgs(&cmd_vgs);
-		/* FIXME: logic for breaking command is not consistent */
-		if (sigint_caught()) {
-			stack;
-			return ECMD_FAILED;
-		}
 	}
 
 	return ret_max;
@@ -438,11 +435,14 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 			ret_max = ret;
 	} else
 		dm_list_iterate_items(pvseg, &pv->segments) {
+			if (sigint_caught()) {
+				ret_max = ECMD_FAILED;
+				stack;
+				break;
+			}
 			ret = process_single_pvseg(cmd, vg, pvseg, handle);
 			if (ret > ret_max)
 				ret_max = ret;
-			if (sigint_caught())
-				break;
 		}
 
 	if (vg_name)
@@ -463,12 +463,11 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 	int ret;
 
 	dm_list_iterate_items(seg, &lv->segments) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
 		ret = process_single_seg(cmd, seg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
-		/* FIXME: logic for breaking command is not consistent */
-		if (sigint_caught())
-			return ECMD_FAILED;
 	}
 
 	return ret_max;
@@ -491,9 +490,9 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 		return_0;
 
 	for (;;) {
-		/* FIXME: consistent handling of command break */
 		if (sigint_caught()) {
 			ret = ECMD_FAILED;
+			stack;
 			break;
 		}
 		if (!cmd_vg_read(cmd, &cmd_vgs))
@@ -502,6 +501,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
 			    (!((flags & READ_ALLOW_INCONSISTENT) &&
 			       (vg_read_error(cvl_vg->vg) == FAILED_INCONSISTENT)))) {
 				ret = ECMD_FAILED;
+				stack;
 				break;
 			}
 
@@ -592,6 +592,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 			return ret_max;
 		}
 		dm_list_iterate_items(sl, vgids) {
+			if (sigint_caught())
+				return_ECMD_FAILED;
 			vgid = sl->str;
 			if (!(vgid) || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
 				continue;
@@ -599,11 +601,11 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 						  &arg_vgnames,
 						  flags, handle,
 					  	  ret_max, process_single_vg);
-			if (sigint_caught())
-				return ret_max;
 		}
 	} else {
 		dm_list_iterate_items(sl, vgnames) {
+			if (sigint_caught())
+				return_ECMD_FAILED;
 			vg_name = sl->str;
 			if (is_orphan_vg(vg_name))
 				continue;	/* FIXME Unnecessary? */
@@ -611,8 +613,6 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 						  &arg_vgnames,
 						  flags, handle,
 					  	  ret_max, process_single_vg);
-			if (sigint_caught())
-				return ret_max;
 		}
 	}
 
@@ -628,14 +628,14 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (sigint_caught())
+			return_ECMD_FAILED;
 		if (tags && !dm_list_empty(tags) &&
 		    !str_list_match_list(tags, &pvl->pv->tags, NULL)) {
 			continue;
 		}
 		if ((ret = process_single_pv(cmd, vg, pvl->pv, handle)) > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
-			return ret_max;
 	}
 
 	return ret_max;
@@ -650,12 +650,10 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	struct device *dev;
 
 	int ret_max = ECMD_PROCESSED;
-	int ret = 0;
+	int ret;
 
-	if (!scan_vgs_for_pvs(cmd, 1)) {
-		stack;
-		return ECMD_FAILED;
-	}
+	if (!scan_vgs_for_pvs(cmd, 1))
+		return_ECMD_FAILED;
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
 		log_error("dev_iter creation failed");
@@ -663,6 +661,12 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	}
 
 	while ((dev = dev_iter_get(iter))) {
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			stack;
+			break;
+		}
+
 		if (!(pv = pv_read(cmd, dev_name(dev), 0, 0))) {
 			memset(&pv_dummy, 0, sizeof(pv_dummy));
 			dm_list_init(&pv_dummy.tags);
@@ -670,14 +674,12 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 			pv_dummy.dev = dev;
 			pv = &pv_dummy;
 		}
-		ret = process_single_pv(cmd, NULL, pv, handle);
-
-		free_pv_fid(pv);
 
+		ret = process_single_pv(cmd, NULL, pv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
-		if (sigint_caught())
-			break;
+
+		free_pv_fid(pv);
 	}
 
 	dev_iter_destroy(iter);
@@ -718,6 +720,10 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
+			if (sigint_caught()) {
+				ret_max = ECMD_FAILED;
+				goto_out;
+			}
 			dm_unescape_colons_and_at_signs(argv[opt], NULL, &at_sign);
 			if (at_sign && (at_sign == argv[opt])) {
 				tagname = at_sign + 1;
@@ -786,22 +792,22 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			}
 
 			ret = process_single_pv(cmd, vg, pv, handle);
-
+			if (ret > ret_max)
+				ret_max = ret;
 			/*
 			 * Free PV only if we called pv_read before,
 			 * otherwise the PV structure is part of the VG.
 			 */
 			if (!vg)
 				free_pv_fid(pv);
-
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
 		}
 		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
+				if (sigint_caught()) {
+					ret_max = ECMD_FAILED;
+					goto_out;
+				}
 				vg = vg_read(cmd, sll->str, NULL, flags);
 				if (vg_read_error(vg)) {
 					ret_max = ECMD_FAILED;
@@ -813,31 +819,20 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				ret = process_each_pv_in_vg(cmd, vg, &tags,
 							    handle,
 							    process_single_pv);
-
-				unlock_and_release_vg(cmd, vg, sll->str);
-
 				if (ret > ret_max)
 					ret_max = ret;
-				if (sigint_caught())
-					goto out;
+
+				unlock_and_release_vg(cmd, vg, sll->str);
 			}
 		}
 	} else {
 		if (vg) {
 			log_verbose("Using all physical volume(s) in "
 				    "volume group");
-			ret = process_each_pv_in_vg(cmd, vg, NULL, handle,
-						    process_single_pv);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
+			ret_max = process_each_pv_in_vg(cmd, vg, NULL, handle,
+							process_single_pv);
 		} else if (arg_count(cmd, all_ARG)) {
-			ret = _process_all_devs(cmd, handle, process_single_pv);
-			if (ret > ret_max)
-				ret_max = ret;
-			if (sigint_caught())
-				goto out;
+			ret_max = _process_all_devs(cmd, handle, process_single_pv);
 		} else {
 			log_verbose("Scanning for physical volume names");
 
@@ -846,13 +841,16 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				goto bad;
 
 			dm_list_iterate_items(pvl, pvslist) {
+				if (sigint_caught()) {
+					ret_max = ECMD_FAILED;
+					goto_out;
+				}
 				ret = process_single_pv(cmd, NULL, pvl->pv,
 						     handle);
-				free_pv_fid(pvl->pv);
 				if (ret > ret_max)
 					ret_max = ret;
-				if (sigint_caught())
-					goto out;
+
+				free_pv_fid(pvl->pv);
 			}
 		}
 	}
@@ -1351,12 +1349,16 @@ int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg)
 
 	sigint_allow();
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (sigint_caught())
-			return_0;
+		if (sigint_caught()) {
+			r = 0;
+			stack;
+			break;
+		}
 
-		if (lv_is_visible(lvl->lv))
-			if (!lv_refresh(cmd, lvl->lv))
-				r = 0;
+		if (lv_is_visible(lvl->lv) && !lv_refresh(cmd, lvl->lv)) {
+			r = 0;
+			stack;
+		}
 	}
 
 	sigint_restore();


