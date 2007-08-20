From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2007 17:05:50 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070820170550.22979.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-20 17:05:49

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for last checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.684&r2=1.685

--- LVM2/WHATS_NEW	2007/08/17 11:51:22	1.684
+++ LVM2/WHATS_NEW	2007/08/20 17:05:49	1.685
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Move guts of lvremove into library.
   Allow clvmd debug to be turned on in a running daemon using clvmd -d
   Update to use autoconf 2.61, while still supporting 2.57.
   Add more cluster info to lvmdump


