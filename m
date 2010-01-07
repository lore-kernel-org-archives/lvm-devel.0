From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 09:42:53 -0000
Subject: LVM2/man fsadm.8.in
Message-ID: <20100107094253.14292.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 09:42:52

Modified files:
	man            : fsadm.8.in 

Log message:
	Fix typo  fsdam -> fsadm   (closes bug 552721)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/fsadm.8.in	2009/02/04 12:47:05	1.2
+++ LVM2/man/fsadm.8.in	2010/01/07 09:42:51	1.3
@@ -2,10 +2,10 @@
 .SH "NAME"
 fsadm \- utility to resize or check filesystem on a device
 .SH "SYNOPSIS"
-.B fsdam
+.B fsadm
 .RI [options]\ check\ device
 
-.B fsdam
+.B fsadm
 .RI [options]\ resize\ device\ [new_size[BKMGTEP]]
 
 .SH "DESCRIPTION"


