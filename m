From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:05:36 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20120227100536.14624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:05:36

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Test result of _init_tags.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2312&r2=1.2313
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/WHATS_NEW	2012/02/27 10:00:23	1.2312
+++ LVM2/WHATS_NEW	2012/02/27 10:05:35	1.2313
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================                       
+  Check for errors in _init_tags() during config loading.
   Always check result of _set_vg_name() in lvcreate.
   Drop unused call to uname() during clvmd initialization.
   Test allocation result in sysfs filter creation.
--- LVM2/lib/commands/toolcontext.c	2012/02/23 13:11:09	1.151
+++ LVM2/lib/commands/toolcontext.c	2012/02/27 10:05:35	1.152
@@ -532,9 +532,10 @@
 	dm_list_add(&cmd->config_files, &cfl->list);
 
       out:
-	if (*tag)
-		_init_tags(cmd, cfl->cft);
-	else
+	if (*tag) {
+		if (!_init_tags(cmd, cfl->cft))
+			return_0;
+	} else
 		/* Use temporary copy of lvm.conf while loading other files */
 		cmd->cft = cfl->cft;
 


