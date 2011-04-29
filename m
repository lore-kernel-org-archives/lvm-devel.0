From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2011 16:23:40 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20110429162340.1412.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-29 16:23:40

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	commands/toolcontext.c:578: warning: ???????udev_dir???????? may be used uninitialized in this function
	commands/toolcontext.c:576: warning: ???????udev_dir_len???????? may be used uninitialized in this function
	
	Bogus - suppress them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/lib/commands/toolcontext.c	2011/04/28 17:33:35	1.117
+++ LVM2/lib/commands/toolcontext.c	2011/04/29 16:23:39	1.118
@@ -573,9 +573,9 @@
 {
 	const struct config_node *cn;
 	const struct config_value *cv;
-	size_t udev_dir_len, len;
+	size_t uninitialized_var(udev_dir_len), len;
 	int device_list_from_udev;
-	const char *udev_dir;
+	const char *uninitialized_var(udev_dir);
 
 	init_dev_disable_after_error_count(
 		find_config_tree_int(cmd, "devices/disable_after_error_count",

