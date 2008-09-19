From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 18:26:43 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20080919182643.12131.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 18:26:42

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	suppress warning if old value found for now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/lib/commands/toolcontext.c	2008/09/19 06:41:58	1.62
+++ LVM2/lib/commands/toolcontext.c	2008/09/19 18:26:41	1.63
@@ -267,6 +267,12 @@
 	cmd->stripe_filler = find_config_tree_str(cmd,
 						  "activation/missing_stripe_filler",
 						  DEFAULT_STRIPE_FILLER);
+
+	/* FIXME Missing error code checks from the stats, not log_warn?, notify if setting overridden, delay message/check till it is actually used (eg consider if lvm shell - file could appear later after this check)? */
+	if (!strcmp(cmd->stripe_filler, "/dev/ioerror") &&
+	    stat(cmd->stripe_filler, &st))
+		cmd->stripe_filler = "error";
+
 	if (strcmp(cmd->stripe_filler, "error")) {
 		if (stat(cmd->stripe_filler, &st)) {
 			log_warn("WARNING: activation/missing_stripe_filler = \"%s\" "


