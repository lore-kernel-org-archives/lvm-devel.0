From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:17:29 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20120301211729.10347.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:17:29

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Log sys errors

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/tools/lvmcmdline.c	2012/02/15 15:18:44	1.151
+++ LVM2/tools/lvmcmdline.c	2012/03/01 21:17:29	1.152
@@ -1390,9 +1390,12 @@
 	if (is_static() && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_SHARED_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {
-		setenv("LVM_DID_EXEC", base, 1);
-		execvp(LVM_SHARED_PATH, argv);
-		unsetenv("LVM_DID_EXEC");
+		if (setenv("LVM_DID_EXEC", base, 1))
+			log_sys_error("setenv", "LVM_DID_EXEC");
+		if (execvp(LVM_SHARED_PATH, argv) == -1)
+			log_sys_error("execvp", "LVM_SHARED_PATH");
+		if (unsetenv("LVM_DID_EXEC"))
+			log_sys_error("unsetenv", "LVM_DID_EXEC");
 	}
 
 	/* "version" command is simple enough so it doesn't need any complex init */


