From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Sep 2011 18:24:27 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20110906182427.11342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-06 18:24:27

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	Detect sscanf recovering_region input error
	
	Missing check for sscanf found by static analyzer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2092&r2=1.2093
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2011/09/06 18:15:43	1.2092
+++ LVM2/WHATS_NEW	2011/09/06 18:24:27	1.2093
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Detect sscanf recovering_region input error in cmirrord pull_state().
   Fix error path bitmap leak in cmirrord import_checkpoint().
   Log unlink() error in cmirrord remove_lockfile().
   Remove incorrect requirement for -j or -m from lvchange error message.
--- LVM2/daemons/cmirrord/functions.c	2010/12/20 13:58:38	1.27
+++ LVM2/daemons/cmirrord/functions.c	2011/09/06 18:24:27	1.28
@@ -1817,8 +1817,11 @@
 	}
 
 	if (!strncmp(which, "recovering_region", 17)) {
-		sscanf(buf, "%llu %u", (unsigned long long *)&lc->recovering_region,
-		       &lc->recoverer);
+		if (sscanf(buf, "%llu %u", (unsigned long long *)&lc->recovering_region,
+			   &lc->recoverer) != 2) {
+			LOG_ERROR("cannot parse recovering region from: %s", buf);
+			return -EINVAL;
+		}
 		LOG_SPRINT(lc, "CKPT INIT - SEQ#=X, UUID=%s, nodeid = X:: "
 			   "recovering_region=%llu, recoverer=%u",
 			   SHORT_UUID(lc->uuid),


