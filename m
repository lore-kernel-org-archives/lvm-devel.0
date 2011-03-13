From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Mar 2011 18:08:27 -0000
Subject: LVM2/daemons/clvmd clvmd-openais.c
Message-ID: <20110313180827.18910.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-13 18:08:26

Modified files:
	daemons/clvmd  : clvmd-openais.c 

Log message:
	Remove compile warning for lock_id.
	
	%llx --> PRIx64

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/daemons/clvmd/clvmd-openais.c	2011/02/22 10:01:11	1.16
+++ LVM2/daemons/clvmd/clvmd-openais.c	2011/03/13 18:08:26	1.17
@@ -509,8 +509,8 @@
 			
 	/* Wait for it to complete */
 
-	DEBUGLOG("lock_resource returning %d, lock_id=%llx\n", err,
-		 lock_id);
+	DEBUGLOG("lock_resource returning %d, lock_id=%" PRIx64 "\n",
+		 err, lock_id);
 
 	linfo->lock_id = lock_id;
 	linfo->res_handle = res_handle;
@@ -531,7 +531,7 @@
 	if (!linfo)
 		return 0;
 
-	DEBUGLOG("unlock_resource: lockid: %llx\n", linfo->lock_id);
+	DEBUGLOG("unlock_resource: lockid: %" PRIx64 "\n", linfo->lock_id);
 	err = saLckResourceUnlock(linfo->lock_id, SA_TIME_END);
 	if (err != SA_AIS_OK)
 	{


