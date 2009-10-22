From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Oct 2009 17:45:24 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20091022174524.14544.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-22 17:45:24

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix clvmd segfault when refresh_toolcontext fails.   (brassow, bz 506986)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1300&r2=1.1301
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2009/10/22 17:33:09	1.1300
+++ LVM2/WHATS_NEW	2009/10/22 17:45:23	1.1301
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Fix clvmd segfault when refresh_toolcontext fails.
   Remember to clear 'global lock held during cache refresh' state after use.
   Use udev flags support in LVM.
   Delay announcing mirror monitoring to syslog until initialisation succeeded.
--- LVM2/daemons/clvmd/lvm-functions.c	2009/10/01 14:14:17	1.69
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/10/22 17:45:24	1.70
@@ -601,20 +601,23 @@
 
 int do_refresh_cache()
 {
-	int ret;
 	DEBUGLOG("Refreshing context\n");
 	log_notice("Refreshing context");
 
 	pthread_mutex_lock(&lvm_lock);
 
-	ret = refresh_toolcontext(cmd);
+	if (!refresh_toolcontext(cmd)) {
+		pthread_mutex_unlock(&lvm_lock);
+		return -1;
+	}
+
 	init_full_scan_done(0);
 	lvmcache_label_scan(cmd, 2);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
 
-	return ret==1?0:-1;
+	return 0;
 }
 
 


