From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 13:45:29 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20081211134529.23843.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 13:45:29

Modified files:
	.              : WHATS_NEW 

Log message:
	

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1007&r2=1.1008

--- LVM2/WHATS_NEW	2008/12/07 19:37:07	1.1007
+++ LVM2/WHATS_NEW	2008/12/11 13:45:28	1.1008
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Refactor init_lvm() for lvmcmdline and clvmd.
   Add liblvm interactive test infrastructure to build.
   Use better random seed value in temp file creation.
   Add generic function to read /dev/urandom, used in uuid calculation.


