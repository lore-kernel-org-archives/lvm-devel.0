From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Jan 2009 17:27:11 -0000
Subject: LVM2/man pvs.8.in
Message-ID: <20090120172711.12058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-20 17:27:11

Modified files:
	man            : pvs.8.in 

Log message:
	Add missing --segments to pvs man pg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/man/pvs.8.in	2009/01/20 17:10:44	1.6
+++ LVM2/man/pvs.8.in	2009/01/20 17:27:11	1.7
@@ -7,7 +7,7 @@
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-\-rows]
+[\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 


