From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 13:19:26 -0000
Subject: LVM2/include .symlinks.in
Message-ID: <20120223131926.24522.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 13:19:26

Modified files:
	include        : .symlinks.in 

Log message:
	Missed update for include/.symlinks.in to include lvmetad.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/include/.symlinks.in	2011/11/11 15:11:09	1.8
+++ LVM2/include/.symlinks.in	2012/02/23 13:19:26	1.9
@@ -4,6 +4,7 @@
 @top_srcdir@/lib/activate/activate.h
 @top_srcdir@/lib/activate/targets.h
 @top_srcdir@/lib/cache/lvmcache.h
+ at top_srcdir@/lib/cache/lvmetad.h
 @top_srcdir@/lib/commands/errors.h
 @top_srcdir@/lib/commands/toolcontext.h
 @top_srcdir@/lib/config/config.h


