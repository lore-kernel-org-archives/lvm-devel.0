From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 30 Apr 2010 13:47:11 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20100430134711.30441.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-30 13:47:11

Modified files:
	tools          : lvmcmdline.c 

Log message:
	And be consistent with return code as well (previous commit).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/tools/lvmcmdline.c	2010/04/30 13:28:44	1.119
+++ LVM2/tools/lvmcmdline.c	2010/04/30 13:47:11	1.120
@@ -1366,7 +1366,7 @@
 
 	/* "version" command is simple enough so it doesn't need any complex init */
 	if (!alias && argc > 1 && !strcmp(argv[1], "version"))
-		return version(NULL, argc, argv);
+		return lvm_return_code(version(NULL, argc, argv));
 
 	if (!(cmd = init_lvm()))
 		return -1;


