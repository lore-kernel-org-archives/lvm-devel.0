From: twoerner@sourceware.org <twoerner@sourceware.org>
Date: 24 Feb 2009 13:13:56 -0000
Subject: LVM2/include .symlinks
Message-ID: <20090224131356.24969.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	twoerner at sourceware.org	2009-02-24 13:13:56

Modified files:
	include        : .symlinks 

Log message:
	Fix include/.symlinks for lvm2.h to lvm.h renaming
	
	Author: Thomas Woerner <twoerner@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/include/.symlinks	2009/02/22 22:11:58	1.56
+++ LVM2/include/.symlinks	2009/02/24 13:13:56	1.57
@@ -1,6 +1,6 @@
 ../daemons/clvmd/clvm.h
 ../daemons/dmeventd/libdevmapper-event.h
-../lib/lvm2.h
+../lib/lvm.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h


