From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jul 2010 11:04:59 -0000
Subject: LVM2 ./WHATS_NEW tools/lvm.c
Message-ID: <20100701110459.31253.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-01 11:04:58

Modified files:
	.              : WHATS_NEW 
	tools          : lvm.c 

Log message:
	Fix lvm shell crash when input is entirely whitespace.  (Xinwei Hu)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1645&r2=1.1646
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/WHATS_NEW	2010/06/30 21:58:13	1.1645
+++ LVM2/WHATS_NEW	2010/07/01 11:04:58	1.1646
@@ -1,5 +1,6 @@
 Version 2.02.70 - 
 ================================
+  Fix lvm shell crash when input is entirely whitespace.
   Update partial mode warning message.
   Preserve memlock balance in clvmd when activation triggers a resume.
 
--- LVM2/tools/lvm.c	2009/12/16 19:22:13	1.111
+++ LVM2/tools/lvm.c	2010/07/01 11:04:58	1.112
@@ -217,6 +217,9 @@
 			continue;
 		}
 
+		if (!argc)
+			continue;
+
 		if (!strcmp(argv[0], "lvm")) {
 			argv++;
 			argc--;


