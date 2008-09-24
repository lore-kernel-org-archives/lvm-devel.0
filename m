From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Sep 2008 16:32:52 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20080924163252.31242.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-24 16:32:51

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Fix validation of --minor and --major in lvcreate to require -My always.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.964&r2=1.965
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177

--- LVM2/WHATS_NEW	2008/09/19 18:31:20	1.964
+++ LVM2/WHATS_NEW	2008/09/24 16:32:51	1.965
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Fix validation of --minor and --major in lvcreate to require -My always.
   Fix release: clvmd build, vgreduce consolidate & tests, /dev/ioerror warning.
 
 Version 2.02.40 - 19th September 2008
--- LVM2/tools/lvcreate.c	2008/07/17 15:19:42	1.176
+++ LVM2/tools/lvcreate.c	2008/09/24 16:32:51	1.177
@@ -500,6 +500,9 @@
 				return 0;
 			}
 		}
+	} else if (arg_count(cmd, minor_ARG) || arg_count(cmd, major_ARG)) {
+		log_error("--major and --minor require -My");
+		return 0;
 	}
 
 	lp->pv_count = argc;


