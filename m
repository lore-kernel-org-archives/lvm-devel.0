From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 23 Aug 2007 12:19:14 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20070823121914.5831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-08-23 12:19:13

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Call init_full_scan_done() when refreshing the cache. This should fix clvmd -R.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.692&r2=1.693
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2007/08/22 20:03:44	1.692
+++ LVM2/WHATS_NEW	2007/08/23 12:19:12	1.693
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Fix clvmd -R, so it fully refreshes the caches.
   Change lvconvert_mirrors to use mirror segtype not striped.
   Fix lvconvert_mirrors detection of number of existing mirrors.
   Clean up numerous compiler warnings that crept in recently.
--- LVM2/daemons/clvmd/lvm-functions.c	2007/08/07 09:06:05	1.31
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/08/23 12:19:13	1.32
@@ -442,9 +442,14 @@
 
 int do_refresh_cache()
 {
+	int ret;
 	DEBUGLOG("Refreshing context\n");
 	log_notice("Refreshing context");
-	return refresh_toolcontext(cmd)==1?0:-1;
+
+	ret = refresh_toolcontext(cmd);
+	init_full_scan_done(0);
+
+	return ret==1?0:-1;
 }
 
 


