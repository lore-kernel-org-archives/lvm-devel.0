From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 May 2011 15:52:50 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110507155250.28348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-07 15:52:50

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1987&r2=1.1988

--- LVM2/WHATS_NEW	2011/04/29 19:05:11	1.1987
+++ LVM2/WHATS_NEW	2011/05/07 15:52:50	1.1988
@@ -1,5 +1,8 @@
 Version 2.02.86 -  
 =================================
+  Avoid memlock size mismatch by preallocating stdio line buffers.
+  Reorganize lvconvert --repair code to allow reuse.
+  Rewrite vgreduce --removemissing --force leveraging shared lvconvert code.
 
 Version 2.02.85 - 29th April 2011
 =================================


