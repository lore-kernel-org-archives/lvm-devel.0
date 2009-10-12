From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 12 Oct 2009 08:33:31 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20091012083331.20044.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-10-12 08:33:30

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Make clvmd return 0 on success rather than 1.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1292&r2=1.1293
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/WHATS_NEW	2009/10/05 20:55:56	1.1292
+++ LVM2/WHATS_NEW	2009/10/12 08:33:30	1.1293
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Make clvmd return 0 on success rather than 1.
   Add --pvmetadatacopies for pvcreate, vgcreate, vgextend, vgconvert.
   Add implict pvcreate support to vgcreate and vgextend.
   Correct example.conf to indicate that lvm2 not lvm1 is the default format.
--- LVM2/daemons/clvmd/clvmd.c	2009/09/01 09:48:01	1.61
+++ LVM2/daemons/clvmd/clvmd.c	2009/10/12 08:33:30	1.62
@@ -303,7 +303,7 @@
 			exit(0);
 
 		case 'R':
-			return refresh_clvmd();
+			return refresh_clvmd()==1?0:1;
 
 		case 'C':
 			clusterwide_opt = 1;
@@ -354,7 +354,7 @@
 		/* Sending to stderr makes no sense for a detached daemon */
 		if (debug == DEBUG_STDERR)
 			debug = DEBUG_SYSLOG;
-		return debug_clvmd(debug, clusterwide_opt);
+		return debug_clvmd(debug, clusterwide_opt)==1?0:1;
 	}
 
 	/* Fork into the background (unless requested not to) */


