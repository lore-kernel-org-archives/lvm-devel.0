From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:05:32 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20101220140532.22941.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:05:32

Modified files:
	tools          : toollib.c 

Log message:
	Remove unused variable dev_dir_provided

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.217&r2=1.218

--- LVM2/tools/toollib.c	2010/12/08 20:50:51	1.217
+++ LVM2/tools/toollib.c	2010/12/20 14:05:31	1.218
@@ -842,7 +842,6 @@
 	const char *vg_name = lv_name;
 	char *st;
 	char *dev_dir = cmd->dev_dir;
-	int dev_dir_provided = 0;
 
 	/* Path supplied? */
 	if (vg_name && strchr(vg_name, '/')) {
@@ -854,7 +853,6 @@
 		}
 		if (!strncmp(vg_name, dev_dir, strlen(dev_dir))) {
 			vg_name += strlen(dev_dir);
-			dev_dir_provided = 1;
 			while (*vg_name == '/')
 				vg_name++;
 		}


