From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 24 Oct 2006 18:49:31 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20061024184931.14050.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2006-10-24 18:49:31

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	- likely cut and paste error.  Fix wrong function name in debug
	output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/daemons/clvmd/lvm-functions.c	2006/10/06 10:06:37	1.24
+++ LVM2/daemons/clvmd/lvm-functions.c	2006/10/24 18:49:31	1.25
@@ -243,7 +243,7 @@
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
 	if (oldmode == -1) {
-		DEBUGLOG("do_deactivate_lock, lock not already held\n");
+		DEBUGLOG("do_resume_lv, lock not already held\n");
 		return 0;	/* We don't need to do anything */
 	}
 


