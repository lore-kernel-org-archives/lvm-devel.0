From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Apr 2009 11:30:50 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20090424113050.27108.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-04-24 11:30:49

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Fix segfault when using -U, -G and -M options in dmsetup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.265&r2=1.266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/WHATS_NEW_DM	2009/03/03 18:25:05	1.265
+++ LVM2/WHATS_NEW_DM	2009/04/24 11:30:49	1.266
@@ -1,5 +1,6 @@
 Version 1.02.32 - 
 ================================
+  Fix segfault when using -U, -G and -M options in dmsetup.
 
 Version 1.02.31 - 3rd March 2009
 ================================
--- LVM2/tools/dmsetup.c	2008/10/30 17:52:06	1.113
+++ LVM2/tools/dmsetup.c	2009/04/24 11:30:49	1.114
@@ -2565,7 +2565,7 @@
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfGj:m:Mno:O:ru:Uv",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:j:m:M:no:O:ru:U:v",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;


