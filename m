From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Nov 2008 01:43:31 -0000
Subject: LVM2 configure.in
Message-ID: <20081101014331.27162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-01 01:43:31

Modified files:
	.              : configure.in 

Log message:
	export DM_LIB_VERSION

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/configure.in	2008/10/31 22:32:09	1.84
+++ LVM2/configure.in	2008/11/01 01:43:31	1.85
@@ -701,6 +701,8 @@
 
 ################################################################################
 DM_LIB_VERSION="\"`cat VERSION_LIB 2>/dev/null || echo Unknown`\""
+AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
+
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################


