From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:14:45 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c daemons/clv ...
Message-ID: <20120301211445.8537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:14:44

Modified files:
	daemons/clvmd  : clvmd-command.c clvmd.c 
	tools          : lvconvert.c toollib.c 

Log message:
	Correct enum type
	
	Using debug_t and some forgetten alloc_policy_t, force_t from past commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.244&r2=1.245

--- LVM2/daemons/clvmd/clvmd-command.c	2012/02/27 10:02:17	1.66
+++ LVM2/daemons/clvmd/clvmd-command.c	2012/03/01 21:14:43	1.67
@@ -153,7 +153,7 @@
 		break;
 
 	case CLVMD_CMD_SET_DEBUG:
-		clvmd_set_debug(args[0]);
+		clvmd_set_debug((debug_t) args[0]);
 		break;
 
 	case CLVMD_CMD_RESTART:
--- LVM2/daemons/clvmd/clvmd.c	2012/03/01 21:12:37	1.130
+++ LVM2/daemons/clvmd/clvmd.c	2012/03/01 21:14:43	1.131
@@ -343,7 +343,7 @@
 	int start_timeout = 0;
 	if_type_t cluster_iface = IF_AUTO;
 	sigset_t ss;
-	int debug_opt = 0;
+	debug_t debug_opt = DEBUG_OFF;
 	debug_t debug_arg = DEBUG_OFF;
 	int clusterwide_opt = 0;
 	mode_t old_mask;
@@ -383,8 +383,8 @@
 			break;
 
 		case 'd':
-			debug_opt = 1;
-			debug_arg = optarg ? atoi(optarg) : DEBUG_STDERR;
+			debug_opt = DEBUG_STDERR;
+			debug_arg = optarg ? (debug_t) atoi(optarg) : DEBUG_STDERR;
 			if (debug_arg == DEBUG_STDERR)
 				foreground_mode = 1;
 			break;
--- LVM2/tools/lvconvert.c	2012/02/28 14:24:58	1.187
+++ LVM2/tools/lvconvert.c	2012/03/01 21:14:43	1.188
@@ -203,7 +203,7 @@
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, SIGN_NONE);
 	}
 
-	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
+	lp->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 	/* There are three types of lvconvert. */
 	if (lp->merge) {	/* Snapshot merge */
@@ -1236,7 +1236,7 @@
 
         if (force && _failed_mirrors_count(lv) == lv_mirror_count(lv)) {
 		log_error("No usable images left in %s.", lv->name);
-		return lv_remove_with_dependencies(cmd, lv, 1, 0);
+		return lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0);
         }
 
 	/*
--- LVM2/tools/toollib.c	2012/02/28 18:08:08	1.244
+++ LVM2/tools/toollib.c	2012/03/01 21:14:43	1.245
@@ -1245,7 +1245,7 @@
 					vp_def->max_lv);
 	vp_new->max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG,
 					vp_def->max_pv);
-	vp_new->alloc = arg_uint_value(cmd, alloc_ARG, vp_def->alloc);
+	vp_new->alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, vp_def->alloc);
 
 	/* Units of 512-byte sectors */
 	vp_new->extent_size =
@@ -1389,7 +1389,7 @@
 	}
 
 	pp->yes = arg_count(cmd, yes_ARG);
-	pp->force = arg_count(cmd, force_ARG);
+	pp->force = (force_t) arg_count(cmd, force_ARG);
 
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
 		log_error("labelsector must be less than %lu",


