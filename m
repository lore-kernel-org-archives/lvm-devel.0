From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 22:58:23 -0000
Subject: LVM2/lib/misc lvm-exec.c
Message-ID: <20120302225823.28539.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 22:58:23

Modified files:
	lib/misc       : lvm-exec.c 

Log message:
	Just space moving
	
	Don't leave space on EOL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/misc/lvm-exec.c	2011/09/19 18:38:43	1.16
+++ LVM2/lib/misc/lvm-exec.c	2012/03/02 22:58:23	1.17
@@ -35,7 +35,7 @@
 	buf[0] = '\0';
 	for (i = 0; argv[i]; i++) {
 		if ((len = dm_snprintf(buf + pos, sz - pos,
-				       "%s ", argv[i])) < 0)
+				       " %s", argv[i])) < 0)
 			/* Truncated */
 			break;
 		pos += len;
@@ -62,7 +62,7 @@
 		if (!sync_local_dev_names(cmd)) /* Flush ops and reset dm cookie */
 			return_0;
 
-	log_verbose("Executing: %s", _verbose_args(argv, buf, sizeof(buf)));
+	log_verbose("Executing:%s", _verbose_args(argv, buf, sizeof(buf)));
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));


