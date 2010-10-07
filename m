From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Oct 2010 16:33:36 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20101007163336.17217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-07 16:33:35

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Allow CC to be overridden at build time (for 'scan-build make').

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1746&r2=1.1747
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/WHATS_NEW	2010/10/05 17:34:05	1.1746
+++ LVM2/WHATS_NEW	2010/10/07 16:33:34	1.1747
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Allow CC to be overridden at build time (for 'scan-build make').
   Rename 'flags' to 'status' in struct metadata_area.
   Avoid segfault by limiting partial mode for lvm1 metadata. (2.02.74)
   Add dm_zalloc and use it and dm_pool_zalloc throughout.
--- LVM2/make.tmpl.in	2010/09/27 19:09:34	1.111
+++ LVM2/make.tmpl.in	2010/10/07 16:33:35	1.112
@@ -17,9 +17,8 @@
 
 @SET_MAKE@
 
-CC = @CC@
+CC ?= @CC@
 RANLIB = @RANLIB@
-SHELL = /bin/sh
 INSTALL = @INSTALL@
 MKDIR_P = @MKDIR_P@
 MSGFMT = @MSGFMT@


