From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:35:32 -0000
Subject: LVM2/include .symlinks.in
Message-ID: <20120228183532.1429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:35:32

Modified files:
	include        : .symlinks.in 

Log message:
	expose new include files to build

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/include/.symlinks.in	2012/02/23 13:19:26	1.9
+++ LVM2/include/.symlinks.in	2012/02/28 18:35:32	1.10
@@ -1,5 +1,6 @@
 @top_srcdir@/daemons/clvmd/clvm.h
 @top_srcdir@/daemons/dmeventd/libdevmapper-event.h
+ at top_srcdir@/daemons/lvmetad/lvmetad-client.h
 @top_srcdir@/liblvm/lvm2app.h
 @top_srcdir@/lib/activate/activate.h
 @top_srcdir@/lib/activate/targets.h
@@ -59,6 +60,8 @@
 @top_srcdir@/lib/report/properties.h
 @top_srcdir@/lib/report/report.h
 @top_srcdir@/lib/uuid/uuid.h
+ at top_srcdir@/libdaemon/client/daemon-client.h
+ at top_srcdir@/libdaemon/client/daemon-shared.h
 @top_srcdir@/libdm/libdevmapper.h
 @top_srcdir@/libdm/misc/dm-ioctl.h
 @top_srcdir@/libdm/misc/dm-logging.h


