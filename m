From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Dec 2011 00:05:40 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20111201000540.23487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-12-01 00:05:40

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW for previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2199&r2=1.2200

--- LVM2/WHATS_NEW	2011/11/30 02:02:10	1.2199
+++ LVM2/WHATS_NEW	2011/12/01 00:05:40	1.2200
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Do not allow users to change permissions on RAID sub-LVs
   Support the ability to replace specific devices in a RAID array via lvconvert.
   Add activation/use_linear_target enabled by default.
   Use gcc warning options only with .c to .o compilation.


