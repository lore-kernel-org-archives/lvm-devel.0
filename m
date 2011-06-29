From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 29 Jun 2011 02:06:27 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20110629020627.26929.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-06-29 02:06:26

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix error message - the parameter name is '--mirrorlog' not '--log'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/tools/lvconvert.c	2011/06/28 21:28:35	1.164
+++ LVM2/tools/lvconvert.c	2011/06/29 02:06:26	1.165
@@ -131,7 +131,7 @@
 	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
 	     arg_count(cmd, repair_ARG))) {
 		log_error("--snapshot or --merge argument cannot be mixed "
-			  "with --mirrors, --repair or --log");
+			  "with --mirrors, --repair or --mirrorlog");
 		return 0;
 	}
 


