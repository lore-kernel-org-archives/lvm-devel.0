From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Jun 2009 11:49:05 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090603114905.21167.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-03 11:49:05

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1138&r2=1.1139

--- LVM2/WHATS_NEW	2009/06/01 15:55:06	1.1138
+++ LVM2/WHATS_NEW	2009/06/03 11:49:05	1.1139
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix makefile to build also shared libraries when running plain make.
   Fix rename of active snapshot with virtual origin.
   Fix convert polling to ignore LV with different UUID.
   Cache underlying device readahead only before activation calls.


