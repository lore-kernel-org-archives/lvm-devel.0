From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 20 Jan 2010 15:17:26 -0000
Subject: LVM2/man cmirrord.8.in
Message-ID: <20100120151726.27631.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-20 15:17:25

Modified files:
	man            : cmirrord.8.in 

Log message:
	Fill in a little more on the man page for cmirrord

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/cmirrord.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/man/cmirrord.8.in	2010/01/19 02:04:34	1.1
+++ LVM2/man/cmirrord.8.in	2010/01/20 15:17:25	1.2
@@ -1,5 +1,13 @@
 .TH CMIRRORD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
 .SH NAME
-cmirrord
+cmirrord \- cluster mirror log daemon
+
 .SH SYNOPSIS
 .B cmirrord
+
+.SH DESCRIPTION
+cmirrord is the daemon that tracks mirror log information in a cluster.
+Cluster mirrors are not possible without this daemon running.
+
+.SH SEE ALSO
+.BR clvmd (8)


