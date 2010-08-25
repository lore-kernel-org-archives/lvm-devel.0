From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 25 Aug 2010 13:06:04 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20100825130604.11531.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-08-25 13:06:03

Modified files:
	doc            : example.conf.in 

Log message:
	Make example.conf description for 'default_data_alignment' more generic.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/doc/example.conf.in	2010/08/20 22:24:58	1.10
+++ LVM2/doc/example.conf.in	2010/08/25 13:06:03	1.11
@@ -99,8 +99,7 @@
     md_chunk_alignment = 1
 
     # Default alignment of the start of a data area in MB.  If set to 0,
-    # a small value of 64KB will be used, which was the default until
-    # LVM2 version 2.02.73.  Set to 1 for 1MiB, 2 for 2MiB, etc.
+    # a value of 64KB will be used.  Set to 1 for 1MiB, 2 for 2MiB, etc.
     # default_data_alignment = @DEFAULT_DATA_ALIGNMENT@
 
     # By default, the start of a PV's data area will be a multiple of


