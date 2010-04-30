From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 30 Apr 2010 13:28:46 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20100430132846.16698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-04-30 13:28:45

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Don't run any complex initialisation for the "version" lvm2 command.
	
	We can use it even in read-only environment where a try to initialise
	file-based locking fails (not to mention other processing related with
	lvm2 init). Simply, we want to output the version only, nothing else.
	And this should always work.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/tools/lvmcmdline.c	2010/04/29 01:38:14	1.118
+++ LVM2/tools/lvmcmdline.c	2010/04/30 13:28:44	1.119
@@ -1364,6 +1364,10 @@
 		unsetenv("LVM_DID_EXEC");
 	}
 
+	/* "version" command is simple enough so it doesn't need any complex init */
+	if (!alias && argc > 1 && !strcmp(argv[1], "version"))
+		return version(NULL, argc, argv);
+
 	if (!(cmd = init_lvm()))
 		return -1;
 


