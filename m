From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:12:09 -0000
Subject: LVM2/lib/commands toolcontext.h
Message-ID: <20080919071209.26724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:12:09

Modified files:
	lib/commands   : toolcontext.h 

Log message:
	rename var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/lib/commands/toolcontext.h	2008/09/19 06:41:58	1.25
+++ LVM2/lib/commands/toolcontext.h	2008/09/19 07:12:08	1.26
@@ -69,7 +69,7 @@
 	unsigned is_static:1;	/* Static binary? */
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
-	unsigned partial_activate:1;
+	unsigned partial_activation:1;
 
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */


