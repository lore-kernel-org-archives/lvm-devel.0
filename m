From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 21 Jan 2008 14:07:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/cnxman-socket.h
Message-ID: <20080121140747.19020.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2008-01-21 14:07:46

Modified files:
	.              : WHATS_NEW 
Removed files:
	daemons/clvmd  : cnxman-socket.h 

Log message:
	Remove redundant cnxman-socket.h file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.774&r2=1.775
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/cnxman-socket.h.diff?cvsroot=lvm2&r1=1.4&r2=NONE

--- LVM2/WHATS_NEW	2008/01/20 01:23:46	1.774
+++ LVM2/WHATS_NEW	2008/01/21 14:07:43	1.775
@@ -1,5 +1,6 @@
 Version 2.02.32 -
 ===================================
+  Remove redundant cnxman-socket.h file from clvmd directory.
   Fix pvs, vgs, lvs error exit status on some error paths.
 
 Version 2.02.31 - 19th January 2008


