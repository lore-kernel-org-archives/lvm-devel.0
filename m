From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Jun 2008 13:06:40 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/c ...
Message-ID: <20080605130640.17912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-05 13:06:39

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/cache      : lvmcache.c 

Log message:
	When activating, if precommitted metadata is still cached, assume it's live.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.881&r2=1.882
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2008/06/05 12:45:53	1.881
+++ LVM2/WHATS_NEW	2008/06/05 13:06:39	1.882
@@ -9,6 +9,7 @@
 
 Version 2.02.37 - 
 =================================
+  When activating, if precommitted metadata is still cached, assume it's live.
   When removing LV symlinks, skip any where the VG name is not determined.
   Drop metadata cache if update fails in vg_revert or vg_commit.
   Avoid spurious duplicate VG messages referring to VGs that are gone.
--- LVM2/lib/activate/activate.c	2008/04/10 21:34:18	1.135
+++ LVM2/lib/activate/activate.c	2008/06/05 13:06:39	1.136
@@ -993,7 +993,11 @@
 	if (!activation())
 		goto activate;
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	/*
+	 * If we're activating and precommitted metadata is still cached,
+	 * we assume it matches the new live metadata.
+	 */
+	if (!(lv = lv_from_lvid(cmd, lvid_s, 1)))
 		return 0;
 
 	if (!_passes_activation_filter(cmd, lv)) {
@@ -1018,7 +1022,11 @@
 	if (!activation())
 		return 1;
 
-	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
+	/*
+	 * If we're activating and precommitted metadata is still cached,
+	 * we assume it matches the new live metadata.
+	 */
+	if (!(lv = lv_from_lvid(cmd, lvid_s, 1)))
 		return 0;
 
 	if (filter && !_passes_activation_filter(cmd, lv)) {
--- LVM2/lib/cache/lvmcache.c	2008/05/28 22:27:47	1.52
+++ LVM2/lib/cache/lvmcache.c	2008/06/05 13:06:39	1.53
@@ -479,8 +479,20 @@
 	if (!_vginfo_is_valid(vginfo))
 		return NULL;
 
+	/*
+	 * Don't return cached data if either:
+	 * (i)  precommitted metadata is requested but we don't have it cached
+	 *      - caller should read it off disk;
+	 * (ii) live metadata is requested but we have precommitted metadata cached
+	 *      and no devices are suspended so caller may read it off disk.
+	 *
+	 * If live metadata is requested but we have precommitted metadata cached
+	 * and devices are suspended, we assume this precommitted metadata has
+	 * already been preloaded and committed so it's OK to return it as live.
+	 * Note that we do not clear the PRECOMMITTED flag.
+	 */
 	if ((precommitted && !vginfo->precommitted) ||
-	    (!precommitted && vginfo->precommitted))
+	    (!precommitted && vginfo->precommitted && !memlock()))
 		return NULL;
 
 	if (!(fid =  vginfo->fmt->ops->create_instance(vginfo->fmt,


