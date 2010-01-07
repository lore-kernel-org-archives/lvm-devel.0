From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 7 Jan 2010 20:42:56 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100107204256.10272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-07 20:42:56

Modified files:
	tools          : lvconvert.c 

Log message:
	The patch fixes some lvconvert issues (WRT mirror <-> mirror).
	
	The default log option for a mirror is 'disk'.  If the log
	type is not explicitly stated on the command line when
	converting from an X-way mirror to a Y-way mirror, 'disk'
	is chosen.  So, if you have a 'core' log mirror and you
	convert, your result will contain a 'disk' log.
	
	This patch remembers what the old log type was.  If the
	user is merely trying to switch the number of mirror
	images, the log type is now kept the same.
	
	There is one historical behaviour I left in place...
	If you have a 2-way, core-log mirror and you use lvconvert to
	specify you want a 2-way mirror - without specifying the
	log type - you will get a 2-way, disk-log mirror.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
	Informal-IRC-ACK-by: agk

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/tools/lvconvert.c	2010/01/06 13:27:07	1.101
+++ LVM2/tools/lvconvert.c	2010/01/07 20:42:55	1.102
@@ -628,6 +628,17 @@
 		return 0;
 	}
 
+	/*
+	 * If we are converting from one type of mirror to another, and
+	 * the type of log wasn't specified, then let's keep the log type
+	 * the same.
+	 */
+	if (existing_mirrors && lp->mirrors &&
+	    (lp->mirrors != existing_mirrors) &&
+	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
+		corelog = first_seg(lv)->log_lv ? 0 : 1;
+	}
+
 	if (repair) {
 		cmd->handles_missing_pvs = 1;
 		cmd->partial_activation = 1;


