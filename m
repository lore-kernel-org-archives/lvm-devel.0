From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jun 2007 20:46:05 -0000
Subject: LVM2 lib/locking/locking.c lib/locking/locking ...
Message-ID: <20070615204605.6027.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-06-15 20:46:05

Modified files:
	lib/locking    : locking.c locking.h 
	man            : vgcfgrestore.8 vgrename.8 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgrestore.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgrename.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/locking/locking.c	2007/06/15 10:11:14	1.36
+++ LVM2/lib/locking/locking.c	2007/06/15 20:46:04	1.37
@@ -44,46 +44,50 @@
 	_sigint_caught = 1;
 }
 
-int sigint_caught() {
+int sigint_caught(void) {
 	return _sigint_caught;
 }
 
-void sigint_clear()
+void sigint_clear(void)
 {
 	_sigint_caught = 0;
 }
 
-/* Temporarily allow keyboard interrupts to be intercepted and noted;
-   saves interrupt handler state for sigint_restore(). Users should
-   use the sigint_caught() predicate to check whether interrupt was
-   requested and act appropriately. Interrupt flags are never
-   automatically cleared by this code, but lvm_run_command() clears
-   the flag before running any command. All other places where the
-   flag needs to be cleared need to call sigint_clear(). */
+/*
+ * Temporarily allow keyboard interrupts to be intercepted and noted;
+ * saves interrupt handler state for sigint_restore().  Users should
+ * use the sigint_caught() predicate to check whether interrupt was
+ * requested and act appropriately.  Interrupt flags are never
+ * cleared automatically by this code, but the tools clear the flag
+ * before running each command in lvm_run_command().  All other places
+ * where the flag needs to be cleared need to call sigint_clear().
+ */
 
-void sigint_allow()
+void sigint_allow(void)
 {
 	struct sigaction handler;
 	sigset_t sigs;
 
-	/* do not overwrite the backed up handler data with our
-	   override ones; we just increase nesting count */
+	/*
+	 * Do not overwrite the backed-up handler data -
+	 * just increase nesting count.
+	 */
 	if (_handler_installed) {
 		_handler_installed++;
 		return;
 	}
 
-	/* grab old sigaction for SIGINT; shall not fail */
+	/* Grab old sigaction for SIGINT: shall not fail. */
 	sigaction(SIGINT, NULL, &handler);
-	handler.sa_flags &= ~SA_RESTART; /* clear restart flag */
+	handler.sa_flags &= ~SA_RESTART; /* Clear restart flag */
 	handler.sa_handler = _catch_sigint;
 
 	_handler_installed = 1;
 
-	/* override the signal handler; shall not fail */
+	/* Override the signal handler: shall not fail. */
 	sigaction(SIGINT, &handler, &_oldhandler);
 
-	/* unmask SIGINT, remember to mask it again on restore */
+	/* Unmask SIGINT.  Remember to mask it again on restore. */
 	sigprocmask(0, NULL, &sigs);
 	if ((_oldmasked = sigismember(&sigs, SIGINT))) {
 		sigdelset(&sigs, SIGINT);
@@ -91,9 +95,8 @@
 	}
 }
 
-void sigint_restore()
+void sigint_restore(void)
 {
-	/* extra call, ignore */
 	if (!_handler_installed)
 		return;
 
@@ -102,7 +105,7 @@
 		return;
 	}
 
-	/* nesting count went down to 0 */
+	/* Nesting count went down to 0. */
 	_handler_installed = 0;
 
 	if (_oldmasked) {
--- LVM2/lib/locking/locking.h	2007/06/15 10:11:14	1.31
+++ LVM2/lib/locking/locking.h	2007/06/15 20:46:04	1.32
@@ -115,11 +115,10 @@
 int resume_lvs(struct cmd_context *cmd, struct list *lvs);
 int activate_lvs_excl(struct cmd_context *cmd, struct list *lvs);
 
-/* interrupt handling */
-
-void sigint_clear();
-void sigint_allow();
-void sigint_restore();
-int sigint_caught();
+/* Interrupt handling */
+void sigint_clear(void);
+void sigint_allow(void);
+void sigint_restore(void);
+int sigint_caught(void);
 
 #endif
--- LVM2/man/vgcfgrestore.8	2007/06/15 16:05:57	1.4
+++ LVM2/man/vgcfgrestore.8	2007/06/15 20:46:04	1.5
@@ -14,10 +14,10 @@
 .SH DESCRIPTION
 .B vgcfgrestore
 allows you to restore the metadata of \fIVolumeGroupName\fP from a text 
-backup file produced by \fBvgcfgbackup\fP.  You can specify a backup file to
-use with the \fP-f\fP option.  If no backup file is specified, the latest
-backup file is used.  A list of backup and archive files of 
-\fIVolumeGroupName\fP may be listed with the \fB-l\fP option.
+backup file produced by \fBvgcfgbackup\fP.  You can specify a backup file 
+with \fP--file\fP.  If no backup file is specified, the most recent
+one is used.  Use \fB--list\fP for a list of the available
+backup and archive files of \fIVolumeGroupName\fP.
 .SH OPTIONS
 .TP
 \fB-l | --list\fP \(em List files pertaining to \fIVolumeGroupName\fP
--- LVM2/man/vgrename.8	2007/05/22 02:51:33	1.3
+++ LVM2/man/vgrename.8	2007/06/15 20:46:04	1.4
@@ -25,7 +25,22 @@
 .TP
 "vgrename vg02 my_volume_group" does the same.
 .TP
-"vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp" renames a volume group with UUID Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to the volume group named "VolGroup00_tmp".  Using the UUID option to name a volume group may be useful in cases where one machine has two physical volumes, each with the same volume group name, but a separate volume group UUID (this situation will cause error messages with lvm commands).  One way duplicate volume group names occur is if an old disk with a root volume is moved to a new machine with its own root volume.  In this case, both volume groups may have the same name (for example, "VolGroup00"), but different UUIDs.
+"vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp"
+changes the name of the Volume Group with UUID
+Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to 
+"VolGroup00_tmp".
+
+All the Volume Groups visible to a system need to have different
+names.  Otherwise many LVM2 commands will refuse to run or give
+warning messages.
+
+This situation could arise when disks are moved between machines.  If
+a disk is connected and it contains a Volume Group with the same name
+as the Volume Group containing your root filesystem the machine might
+not even boot correctly.  However, the two Volume Groups should have
+different UUIDs (unless the disk was cloned) so you can rename
+one of the conflicting Volume Groups with
+\fBvgrename\fP.
 .TP
 .SH SEE ALSO
 .BR lvm (8), 


