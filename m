From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 8 Jun 2011 08:49:54 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/lvm-file.c
Message-ID: <20110608084954.2300.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-06-08 08:49:54

Modified files:
	.              : WHATS_NEW 
	lib/misc       : lvm-file.c 

Log message:
	Fix create_temp_name to replace any '/' found in the hostname with '?'.
	
	There's a possibility someone will use the '/' in the hostname. Since we
	generate a temporary file name (path) including the hostname, any '/' would
	be ambiguous.
	
	We can always set such hostname using 'sethostname' from unistd.h. But the
	'hostname' command already includes the check and removes the '/' char.
	However, some old versions still allow that.
	See: https://bugzilla.redhat.com/show_bug.cgi?id=711445.
	
	Since this is only a temporary name and the possibility of this error is
	quite negligible, we don't need any complex escape sequence here, just a
	simple char replace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2006&r2=1.2007
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2011/06/02 09:02:03	1.2006
+++ LVM2/WHATS_NEW	2011/06/08 08:49:53	1.2007
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Fix create_temp_name to replace any '/' found in the hostname with '?'.
   Always use append to file in lvmdump (selinux policy - no file truncation).
   Propagate test mode to clvmd to skip activation and changes to held locks.
   Defer writing PV labels to vg_write.
--- LVM2/lib/misc/lvm-file.c	2009/07/15 20:02:47	1.27
+++ LVM2/lib/misc/lvm-file.c	2011/06/08 08:49:54	1.28
@@ -35,6 +35,7 @@
 	int i, num;
 	pid_t pid;
 	char hostname[255];
+	char *p;
 	struct flock lock = {
 		.l_type = F_WRLCK,
 		.l_whence = 0,
@@ -48,6 +49,12 @@
 		log_sys_error("gethostname", "");
 		strcpy(hostname, "nohostname");
 	}
+	else {
+		/* Replace any '/' with '?' found in the hostname. */
+		p = hostname;
+		while ((p = strchr(p, '/')))
+			*p = '?';
+	}
 
 	for (i = 0; i < 20; i++, num++) {
 


