From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 25 Aug 2010 16:33:47 -0500
Subject: [PATCH] Fix zombie mirror poll daemon (bug 585328)
Message-ID: <1282772027.18079.3.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/tools/polldaemon.c
===================================================================
--- LVM2.orig/tools/polldaemon.c
+++ LVM2/tools/polldaemon.c
@@ -78,7 +78,8 @@ progress_t poll_mirror_progress(struct c
 	percent_range_t percent_range, overall_percent_range;
 	uint32_t event_nr = 0;
 
-	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
+	if (!(lv->status & MIRRORED) ||
+	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
 			       &percent_range, &event_nr) ||
 	    (percent_range == PERCENT_INVALID)) {
 		log_error("ABORTING: Mirror percentage check failed.");



