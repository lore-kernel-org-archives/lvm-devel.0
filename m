From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 2 Feb 2010 08:54:30 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20100202085430.31835.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2010-02-02 08:54:29

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Make clvmd -V return zero status rather than 1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1413&r2=1.1414
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/WHATS_NEW	2010/01/27 22:28:05	1.1413
+++ LVM2/WHATS_NEW	2010/02/02 08:54:29	1.1414
@@ -1,3 +1,8 @@
+Version 2.02.60 - 
+===================================
+  Make clvmd -V return zero status.
+
+
 Version 2.02.60 - 23rd January 2010
 ===================================
   Fix lvconvert issue with cluster mirrors due to un'_safe' list processing
--- LVM2/daemons/clvmd/clvmd.c	2009/10/12 08:33:30	1.62
+++ LVM2/daemons/clvmd/clvmd.c	2010/02/02 08:54:29	1.63
@@ -342,7 +342,7 @@
 			printf("Protocol version:           %d.%d.%d\n",
 			       CLVMD_MAJOR_VERSION, CLVMD_MINOR_VERSION,
 			       CLVMD_PATCH_VERSION);
-			exit(1);
+			exit(0);
 			break;
 
 		}


