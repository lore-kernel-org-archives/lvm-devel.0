From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Jun 2010 08:29:34 -0000
Subject: LVM2 ./WHATS_NEW lib/mm/memlock.c
Message-ID: <20100624082934.5824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-06-24 08:29:31

Modified files:
	.              : WHATS_NEW 
	lib/mm         : memlock.c 

Log message:
	Preload libc locale messages.
	
	Preload libc.mo file for localized lvm before taking memory lock - this way
	we prevent disk access for some error paths in libdm, that prints localized
	errno messages while they are still in memory locked state.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1634&r2=1.1635
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2010/06/23 21:01:42	1.1634
+++ LVM2/WHATS_NEW	2010/06/24 08:29:30	1.1635
@@ -1,5 +1,6 @@
 Version 2.02.69 - 
 ================================
+  Preload libc locale messages to prevent reading it in memory locked state.
   Fix handling of simultaneous mirror image and mirrored log image failure.
 
 Version 2.02.68 - 23rd June 2010
--- LVM2/lib/mm/memlock.c	2010/04/01 14:53:47	1.26
+++ LVM2/lib/mm/memlock.c	2010/06/24 08:29:31	1.27
@@ -216,6 +216,9 @@
 #endif
 	}
 
+	/* Force libc.mo load */
+	if (lock == LVM_MLOCK)
+		(void)strerror(0);
 	/* Reset statistic counters */
 	*mstats = 0;
 	rewind(_mapsh);


