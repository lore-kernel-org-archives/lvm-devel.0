From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Sep 2009 15:11:07 -0000
Subject: LVM2/man lvcreate.8.in
Message-ID: <20090929151107.10284.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-29 15:11:06

Modified files:
	man            : lvcreate.8.in 

Log message:
	Trivial cleanup to lvcreate man page - use virtualsize in example.
	
	virtualsize replaced virtualoriginsize but the example was never updated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/man/lvcreate.8.in	2009/08/10 17:23:04	1.10
+++ LVM2/man/lvcreate.8.in	2009/09/29 15:11:06	1.11
@@ -205,7 +205,7 @@
 arbitrary directory in order to access the contents of the filesystem to run
 a backup while the original filesystem continues to get updated.
 
-"lvcreate --virtualoriginsize 1T --size 100M --snapshot --name sparse vg1"
+"lvcreate --virtualsize 1T --size 100M --snapshot --name sparse vg1"
 .br
 creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
 under 100MB of actual data on it.


