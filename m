From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 12:14:22 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c ./WHATS_NEW
Message-ID: <20101222121422.20394.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 12:14:20

Modified files:
	daemons/clvmd  : clvmd-command.c 
	.              : WHATS_NEW 

Log message:
	Fix memory leak in debug mode of restart_clvmd() error path

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1851&r2=1.1852

--- LVM2/daemons/clvmd/clvmd-command.c	2010/12/17 12:37:49	1.44
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/12/22 12:14:11	1.45
@@ -408,6 +408,7 @@
 	for (i = 0; i < argc && argv[i]; i++)
 		free(argv[i]);
 	free(argv);
+	free(debug_arg);
 
 	return 0;
 }
--- LVM2/WHATS_NEW	2010/12/22 12:10:56	1.1851
+++ LVM2/WHATS_NEW	2010/12/22 12:14:17	1.1852
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Fix memory leak in debug mode of restart_clvmd() error path.
   Log error message for pthread_join() failure in clvmd.
 
 Version 2.02.79 - 20th December 2010


