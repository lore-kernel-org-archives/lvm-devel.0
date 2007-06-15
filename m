From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jun 2007 10:11:15 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/loc ...
Message-ID: <20070615101115.24088.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2007-06-15 10:11:15

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c locking.h 
	tools          : lvchange.c lvmcmdline.c lvresize.c pvcreate.c 
	                 toollib.c 

Log message:
	Allow keyboard interrupts in yes_no_prompt(). Add code to toollib.c
	loops and to pvcreate.c, lvchange.c and lvresize.c to handle
	interrupted prompts.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.632&r2=1.633
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2007/06/14 10:16:34	1.632
+++ LVM2/WHATS_NEW	2007/06/15 10:11:14	1.633
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Allow keyboard interrupt in user prompts where appropriate.
   Remove system-lv code from clvmd. It's highly dodgy and never used.
   Convert a lot of code pv dereferences to use get_pv_* functions.
   Suppress a couple benign warnings by adding variable initializations.
--- LVM2/lib/locking/locking.c	2006/11/30 23:11:41	1.35
+++ LVM2/lib/locking/locking.c	2007/06/15 10:11:14	1.36
@@ -34,6 +34,87 @@
 static int _vg_write_lock_held = 0;	/* VG write lock held? */
 static int _signals_blocked = 0;
 
+static volatile sig_atomic_t _sigint_caught = 0;
+static volatile sig_atomic_t _handler_installed;
+static struct sigaction _oldhandler;
+static int _oldmasked;
+
+static void _catch_sigint(int unused __attribute__((unused)))
+{
+	_sigint_caught = 1;
+}
+
+int sigint_caught() {
+	return _sigint_caught;
+}
+
+void sigint_clear()
+{
+	_sigint_caught = 0;
+}
+
+/* Temporarily allow keyboard interrupts to be intercepted and noted;
+   saves interrupt handler state for sigint_restore(). Users should
+   use the sigint_caught() predicate to check whether interrupt was
+   requested and act appropriately. Interrupt flags are never
+   automatically cleared by this code, but lvm_run_command() clears
+   the flag before running any command. All other places where the
+   flag needs to be cleared need to call sigint_clear(). */
+
+void sigint_allow()
+{
+	struct sigaction handler;
+	sigset_t sigs;
+
+	/* do not overwrite the backed up handler data with our
+	   override ones; we just increase nesting count */
+	if (_handler_installed) {
+		_handler_installed++;
+		return;
+	}
+
+	/* grab old sigaction for SIGINT; shall not fail */
+	sigaction(SIGINT, NULL, &handler);
+	handler.sa_flags &= ~SA_RESTART; /* clear restart flag */
+	handler.sa_handler = _catch_sigint;
+
+	_handler_installed = 1;
+
+	/* override the signal handler; shall not fail */
+	sigaction(SIGINT, &handler, &_oldhandler);
+
+	/* unmask SIGINT, remember to mask it again on restore */
+	sigprocmask(0, NULL, &sigs);
+	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
+		sigdelset(&sigs, SIGINT);
+		sigprocmask(SIG_SETMASK, &sigs, NULL);
+	}
+}
+
+void sigint_restore()
+{
+	/* extra call, ignore */
+	if (!_handler_installed)
+		return;
+
+	if (_handler_installed > 1) {
+		_handler_installed--;
+		return;
+	}
+
+	/* nesting count went down to 0 */
+	_handler_installed = 0;
+
+	if (_oldmasked) {
+		sigset_t sigs;
+		sigprocmask(0, NULL, &sigs);
+		sigaddset(&sigs, SIGINT);
+		sigprocmask(SIG_SETMASK, &sigs, NULL);
+	}
+
+	sigaction(SIGINT, &_oldhandler, NULL);
+}
+
 static void _block_signals(int flags __attribute((unused)))
 {
 	sigset_t set;
--- LVM2/lib/locking/locking.h	2007/01/19 22:21:45	1.30
+++ LVM2/lib/locking/locking.h	2007/06/15 10:11:14	1.31
@@ -115,4 +115,11 @@
 int resume_lvs(struct cmd_context *cmd, struct list *lvs);
 int activate_lvs_excl(struct cmd_context *cmd, struct list *lvs);
 
+/* interrupt handling */
+
+void sigint_clear();
+void sigint_allow();
+void sigint_restore();
+int sigint_caught();
+
 #endif
--- LVM2/tools/lvchange.c	2007/01/24 23:43:27	1.78
+++ LVM2/tools/lvchange.c	2007/06/15 10:11:14	1.79
@@ -212,6 +212,9 @@
 				return ECMD_FAILED;
 			}
 
+			if (sigint_caught())
+				return ECMD_FAILED;
+
 			active = 1;
 		}
 	}
@@ -454,6 +457,10 @@
 				  lv->name);
 			return 0;
 		}
+
+		if (sigint_caught())
+			return 0;
+
 		log_verbose("Ensuring %s is inactive.", lv->name);
 		if (!deactivate_lv(cmd, lv)) {
 			log_error("%s: deactivation failed", lv->name);
@@ -626,6 +633,8 @@
 			return ECMD_FAILED;
 		archived = 1;
 		doit += lvchange_persistent(cmd, lv);
+		if (sigint_caught())
+			return ECMD_FAILED;
 	}
 
 	/* add tag */
--- LVM2/tools/lvmcmdline.c	2007/04/26 16:44:59	1.42
+++ LVM2/tools/lvmcmdline.c	2007/06/15 10:11:14	1.43
@@ -373,6 +373,7 @@
 	int c = 0, ret = 0;
 	va_list ap;
 
+	sigint_allow();
 	do {
 		if (c == '\n' || !c) {
 			va_start(ap, prompt);
@@ -390,6 +391,8 @@
 			ret = c;
 	} while (!ret || c != '\n');
 
+	sigint_restore();
+
 	if (c != '\n')
 		printf("\n");
 
@@ -865,6 +868,9 @@
 	int ret = 0;
 	int locking_type;
 
+	/* each command should start out with sigint flag cleared */
+	sigint_clear();
+
 	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))
 		return ECMD_FAILED;
 
--- LVM2/tools/lvresize.c	2007/06/06 19:40:28	1.77
+++ LVM2/tools/lvresize.c	2007/06/15 10:11:14	1.78
@@ -485,6 +485,8 @@
 						  "reduced", lp->lv_name);
 					return ECMD_FAILED;
 				}
+				if (sigint_caught())
+					return ECMD_FAILED;
 			}
 		}
 	}
--- LVM2/tools/pvcreate.c	2007/06/14 15:48:04	1.51
+++ LVM2/tools/pvcreate.c	2007/06/15 10:11:14	1.52
@@ -58,6 +58,9 @@
 		return 0;
 	}
 
+	if (sigint_caught())
+		return 0;
+
 	dev = dev_cache_get(name, cmd->filter);
 
 	/* Is there an md superblock here? */
@@ -103,6 +106,9 @@
 		}
 	}
 
+	if (sigint_caught())
+		return 0;
+
 	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG)) {
 		log_print("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
@@ -173,6 +179,9 @@
 	if (!pvcreate_check(cmd, pv_name))
 		goto error;
 
+	if (sigint_caught())
+		goto error;
+
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, 0) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
 		goto error;
@@ -309,6 +318,8 @@
 		r = pvcreate_single(cmd, argv[i], &pp);
 		if (r > ret)
 			ret = r;
+		if (sigint_caught())
+			return ret;
 	}
 
 	return ret;
--- LVM2/tools/toollib.c	2007/06/06 19:40:28	1.99
+++ LVM2/tools/toollib.c	2007/06/15 10:11:14	1.100
@@ -209,6 +209,8 @@
 		ret = process_single(cmd, lvl->lv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
+		if (sigint_caught())
+			return ret_max;
 	}
 
 	if (lvargs_supplied && lvargs_matched != list_size(arg_lvnames)) {
@@ -407,6 +409,8 @@
 		unlock_vg(cmd, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
+		if (sigint_caught())
+			return ret_max;
 	}
 
 	return ret_max;
@@ -429,6 +433,8 @@
 		ret = process_single(cmd, vg, pvseg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
+		if (sigint_caught())
+			return ret_max;
 	}
 
 	return ret_max;
@@ -449,6 +455,8 @@
 		ret = process_single(cmd, seg, handle);
 		if (ret > ret_max)
 			ret_max = ret;
+		if (sigint_caught())
+			return ret_max;
 	}
 
 	return ret_max;
@@ -498,6 +506,9 @@
 		ret_max = ret;
 	}
 
+	if (sigint_caught())
+		return ret_max;
+
 	unlock_vg(cmd, vg_name);
 
 	return ret_max;
@@ -573,6 +584,8 @@
 						  &arg_vgnames,
 					  	  lock_type, consistent, handle,
 					  	  ret_max, process_single);
+			if (sigint_caught())
+				return ret_max;
 		}
 	} else {
 		list_iterate_items(sl, vgnames) {
@@ -583,6 +596,8 @@
 						  &arg_vgnames,
 					  	  lock_type, consistent, handle,
 					  	  ret_max, process_single);
+			if (sigint_caught())
+				return ret_max;
 		}
 	}
 
@@ -607,6 +622,8 @@
 		}
 		if ((ret = process_single(cmd, vg, pvl->pv, handle)) > ret_max)
 			ret_max = ret;
+		if (sigint_caught())
+			return ret_max;
 	}
 
 	return ret_max;
@@ -643,6 +660,8 @@
 		ret = process_single(cmd, NULL, pv, handle);
 		if (ret > ret_max)
 			ret_max = ret;
+		if (sigint_caught())
+			return ret_max;
 	}
 
 	dev_iter_destroy(iter);
@@ -715,6 +734,8 @@
 			ret = process_single(cmd, vg, pv, handle);
 			if (ret > ret_max)
 				ret_max = ret;
+			if (sigint_caught())
+				return ret_max;
 		}
 		if (!list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
 		    !list_empty(vgnames)) {
@@ -735,6 +756,8 @@
 							    process_single);
 				if (ret > ret_max)
 					ret_max = ret;
+				if (sigint_caught())
+					return ret_max;
 			}
 		}
 	} else {
@@ -745,10 +768,14 @@
 						    process_single);
 			if (ret > ret_max)
 				ret_max = ret;
+			if (sigint_caught())
+				return ret_max;
 		} else if (arg_count(cmd, all_ARG)) {
 			ret = _process_all_devs(cmd, handle, process_single);
 			if (ret > ret_max)
 				ret_max = ret;
+			if (sigint_caught())
+				return ret_max;
 		} else {
 			log_verbose("Scanning for physical volume names");
 			if (!(pvslist = get_pvs(cmd)))
@@ -759,6 +786,8 @@
 						     handle);
 				if (ret > ret_max)
 					ret_max = ret;
+				if (sigint_caught())
+					return ret_max;
 			}
 		}
 	}


