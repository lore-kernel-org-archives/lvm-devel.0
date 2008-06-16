From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jun 2008 14:16:03 -0000
Subject: LVM2/man lvcreate.8
Message-ID: <20080616141603.5648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-16 14:16:02

Modified files:
	man            : lvcreate.8 

Log message:
	Trivial fix to lvcreate man page for --mirrorlog option.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/man/lvcreate.8	2007/12/05 22:11:20	1.21
+++ LVM2/man/lvcreate.8	2008/06/16 14:16:02	1.22
@@ -11,7 +11,7 @@
 {\-l/\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|log}] [\-\-corelog]
+[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
 [\-R/\-\-regionsize MirrorLogRegionSize]]
 [\-n/\-\-name LogicalVolumeName]
 [\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]


