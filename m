From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 30 Aug 2010 18:37:43 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c
Message-ID: <20100830183743.13927.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-30 18:37:42

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 

Log message:
	This patch fixes an issue where cluster mirror write I/O
	can be opprobriously slow if created with '--nosync'.
	
	One of the ways cluster mirrors coordinate I/O and recovery
	amoung the different machines is by the use of the log
	function 'is_remote_recovering()' which lets nodes know if
	a region they wish to perform a write on is currently being
	recovered on another node.  If the region is being recovered,
	the I/O is delayed.
	
	The 'is_remote_recovering' routine has been optimized to
	avoid the deluge of requests that would be issued to the
	userspace log server by maintaining a marker of how far
	the recovery has gotten.  It can then immediately return
	'not recovering' if the region being inquired about is
	less than this mark.  Additionally, if the region of
	concern is greater than the mark, the function will
	limit the number of transmissions to userspace by assuming
	the region /is/ being recovered when skipping the
	transmission.  This limits the amount of processing
	and updates the mark in 1/4 sec time steps.
	
	This patch fixes a problem where 'the mark' is not being
	updated because of faulty logic in the userspace log
	daemon.  When '--nosync' is used to create a cluster
	mirror, the userspace log daemon never has a chance
	to update the mark in the normal way.  The fix is to set
	the mark to "complete" if the mirror was created with
	the --nosync flag.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1726&r2=1.1727
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2010/08/26 16:29:12	1.1726
+++ LVM2/WHATS_NEW	2010/08/30 18:37:42	1.1727
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Fix opprobriously slow I/O to cluster mirrors created with --nosync.
   Make poll_mirror_progress report PROGRESS_CHECK_FAILED if LV is not a mirror.
   Like mirrors, don't scan origins if ignore_suspended_devices() is set.
   Fix return type qualifier to avoid compiler warning. (2.02.69)
--- LVM2/daemons/cmirrord/functions.c	2010/08/17 23:56:24	1.23
+++ LVM2/daemons/cmirrord/functions.c	2010/08/30 18:37:42	1.24
@@ -1268,6 +1268,7 @@
 		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Resync work complete.",
 			   rq->seq, SHORT_UUID(lc->uuid), originator);
+		lc->sync_search = lc->region_count + 1;
 		return 0;
 	}
 


