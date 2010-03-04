From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 09:46:38 -0000
Subject: LVM2 WHATS_NEW configure.in
Message-ID: <20100304094638.19279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 09:46:38

Modified files:
	.              : WHATS_NEW configure.in 

Log message:
	Usage of AC_PROG_SED and AC_PROG_MKDIR_P requires autoconf version 2.61.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1442&r2=1.1443
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2010/03/02 21:56:14	1.1442
+++ LVM2/WHATS_NEW	2010/03/04 09:46:38	1.1443
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Increase AC_PREREQ version to 2.61 (for AC_PROC_SED, AC_PROG_MKDIR_P).
   Handle a misaligned device that reports a -1 alignment_offset.
   Extend core allocation code in preparation for mirrored log areas.
   Rewrite clvmd init script.
--- LVM2/configure.in	2010/01/21 22:15:45	1.124
+++ LVM2/configure.in	2010/03/04 09:46:38	1.125
@@ -11,7 +11,7 @@
 ## Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 ################################################################################
 
-AC_PREREQ(2.57)
+AC_PREREQ(2.61)
 ################################################################################
 dnl -- Process this file with autoconf to produce a configure script.
 AC_INIT


