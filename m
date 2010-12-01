From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 10:46:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20101201104621.31364.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 10:46:21

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Add logging for pipe write() and close() error
	
	Check values from write() and close() system calls.
	
	FIXME: Missing wrapper around 'write()'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1821&r2=1.1822
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/WHATS_NEW	2010/12/01 10:39:28	1.1821
+++ LVM2/WHATS_NEW	2010/12/01 10:46:20	1.1822
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Add logging for pipe write() and close() error in clvmd child_init_signal().
   Add test for existance of orphan vginfo in _lvmcache_update_vgname().
   Do a full rescan if some device is missing in read_pvs_in_vg().
   Avoid misleading warnings in vgextend --restoremissing in certain cases.
--- LVM2/daemons/clvmd/clvmd.c	2010/11/29 12:44:52	1.84
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/01 10:46:20	1.85
@@ -180,9 +180,12 @@
 /* Called to signal the parent how well we got on during initialisation */
 static void child_init_signal(int status)
 {
-        if (child_pipe[1]) {
-	        write(child_pipe[1], &status, sizeof(status));
-		close(child_pipe[1]);
+	if (child_pipe[1]) {
+		/* FIXME Use a proper wrapper around write */
+		if (write(child_pipe[1], &status, sizeof(status)) < 0)
+			log_sys_error("write", "child_pipe");
+		if (close(child_pipe[1]))
+			log_sys_error("close", "child_pipe");
 	}
 }
 


