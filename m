From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2008 13:16:04 -0000
Subject: LVM2 Makefile.in
Message-ID: <20081118131604.28336.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-11-18 13:16:03

Modified files:
	.              : Makefile.in 

Log message:
	daemons depends on liblvm2cmd - fixes parallel builds

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/Makefile.in	2008/11/10 14:04:12	1.29
+++ LVM2/Makefile.in	2008/11/18 13:16:03	1.30
@@ -42,7 +42,7 @@
 
 libdm: include
 lib: libdm
-daemons: lib
+daemons: lib tools
 tools: lib device-mapper
 po: tools daemons
 


