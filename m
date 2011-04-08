From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2011 14:13:08 -0000
Subject: LVM2/lib locking/file_locking.c log/log.c
Message-ID: <20110408141308.10185.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-08 14:13:08

Modified files:
	lib/locking    : file_locking.c 
	lib/log        : log.c 

Log message:
	Fix some forgotten -Wold-style-definition gcc warnings

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/lib/locking/file_locking.c	2011/02/18 00:36:05	1.58
+++ LVM2/lib/locking/file_locking.c	2011/04/08 14:13:08	1.59
@@ -334,11 +334,12 @@
 
 int init_file_locking(struct locking_type *locking, struct cmd_context *cmd)
 {
+	int r;
+
 	locking->lock_resource = _file_lock_resource;
 	locking->reset_locking = _reset_file_locking;
 	locking->fin_locking = _fin_file_locking;
 	locking->flags = 0;
-	int r;
 
 	/* Get lockfile directory from config file */
 	strncpy(_lock_dir, find_config_tree_str(cmd, "global/locking_dir",
--- LVM2/lib/log/log.c	2011/03/30 12:53:04	1.62
+++ LVM2/lib/log/log.c	2011/04/08 14:13:08	1.63
@@ -127,7 +127,7 @@
 	}
 }
 
-void fin_syslog()
+void fin_syslog(void)
 {
 	if (_syslog)
 		closelog();


