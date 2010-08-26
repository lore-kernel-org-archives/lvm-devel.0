From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 26 Aug 2010 16:29:14 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c
Message-ID: <20100826162914.23599.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-26 16:29:13

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c 

Log message:
	This patch fixes a problem where the mirror polling process
	may never complete.
	
	If you convert from a linear to a mirror and then convert that
	mirror back to linear /while/ the previous (up)convert is
	taking place, the mirror polling process will never complete.
	This is because the function that polls the mirror for
	completion doesn't check if it is still polling a mirror and
	the copy_percent that it gets back from the linear device is
	certainly never 100%.
	
	The fix is simply to check if the daemon is still looking at
	a mirror device - if not, return PROGRESS_CHECK_FAILED.
	
	The user sees the following output from the first (up)convert
	if someone else sneaks in and does a down-convert shortly
	after their convert:
	[root at bp-01 ~]# lvconvert -m1 vg/lv
	vg/lv: Converted: 43.4%
	ABORTING: Mirror percentage check failed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1725&r2=1.1726
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2010/08/26 14:21:50	1.1725
+++ LVM2/WHATS_NEW	2010/08/26 16:29:12	1.1726
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Make poll_mirror_progress report PROGRESS_CHECK_FAILED if LV is not a mirror.
   Like mirrors, don't scan origins if ignore_suspended_devices() is set.
   Fix return type qualifier to avoid compiler warning. (2.02.69)
   Automatically generate LSB Requires-Start for clvmd init script.
--- LVM2/tools/polldaemon.c	2010/08/23 11:34:41	1.36
+++ LVM2/tools/polldaemon.c	2010/08/26 16:29:12	1.37
@@ -78,7 +78,8 @@
 	percent_range_t percent_range, overall_percent_range;
 	uint32_t event_nr = 0;
 
-	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
+	if (!lv_is_mirrored(lv) ||
+	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
 			       &percent_range, &event_nr) ||
 	    (percent_range == PERCENT_INVALID)) {
 		log_error("ABORTING: Mirror percentage check failed.");


