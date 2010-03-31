From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Mar 2010 07:37:18 -0000
Subject: LVM2/tools Makefile.in
Message-ID: <20100331073718.5566.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-31 07:37:16

Modified files:
	tools          : Makefile.in 

Log message:
	Use .commands created in builddir for symlink installation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/tools/Makefile.in	2010/03/29 14:18:01	1.113
+++ LVM2/tools/Makefile.in	2010/03/31 07:37:16	1.114
@@ -179,7 +179,7 @@
 		$(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
 	@( \
-		for v in `cat $(srcdir)/.commands`; do \
+		for v in `cat .commands`; do \
 			cd $(sbindir); \
 			$(LN_S) -f lvm $$v; \
 		done; \


