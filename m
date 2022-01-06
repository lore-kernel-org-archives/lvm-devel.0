From: David Teigland <teigland@sourceware.org>
Date: Thu,  6 Jan 2022 19:09:47 +0000 (GMT)
Subject: main - handle duplicate vgids
Message-ID: <20220106190947.DDDDD3858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd2baeaaa67da3885df9f06700565dc201c82861
Commit:        bd2baeaaa67da3885df9f06700565dc201c82861
Parent:        42a16aa6f34d801bfea169b4f6d1fef5d89961f6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 6 10:15:16 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 6 10:15:16 2022 -0600

handle duplicate vgids

The approach to duplicate VGIDs has been that it is not possible
or not allowed, so the behavior has been undefined.  The actual
result was unpredictable and/or broken, and generally unhelpful.

Improve this by recognizing the problem, displaying the VGs,
and printing a warning to fix the problem.  Beyond this,
using VGs with duplicate VGIDs remains undefined, but should
work well enough to correct the problem with vgchange -u.

It's possible to create this condition without too much difficulty
by cloning PVs, followed by an incomplete attempt at making the two
VGs unique (vgrename and pvchange -u, but missing vgchange -u.)
---
 lib/cache/lvmcache.c         | 20 +++++++++++++----
 test/shell/duplicate-vgid.sh | 52 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c5359f3c5..9c1619b7e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -354,9 +354,11 @@ static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vg
 	if (vgid_arg) {
 		if ((vginfo = dm_hash_lookup(_vgid_hash, vgid))) {
 			if (vgname && strcmp(vginfo->vgname, vgname)) {
-				/* should never happen */
-				log_error(INTERNAL_ERROR "vginfo_lookup vgid %s has two names %s %s",
-					  vgid, vginfo->vgname, vgname);
+				log_warn("WARNING: lookup found duplicate VGID %s for VGs %s and %s.", vgid, vginfo->vgname, vgname);
+				if ((vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
+					if (!memcmp(vginfo->vgid, vgid, ID_LEN))
+						return vginfo;
+				}
 				return NULL;
 			}
 			return vginfo;
@@ -1884,7 +1886,17 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 
 	_drop_vginfo(info, info->vginfo);
 
-	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid))) {
+	vginfo = lvmcache_vginfo_from_vgid(vgid);
+	if (vginfo && strcmp(vginfo->vgname, vgname)) {
+		log_warn("WARNING: fix duplicate VGID %s for VGs %s and %s (see vgchange -u).", vgid_dashed, vgname, vginfo->vgname);
+		vginfo = lvmcache_vginfo_from_vgname(vgname, NULL);
+		if (vginfo && memcmp(vginfo->vgid, vgid, ID_LEN)) {
+			log_error("Ignoring %s with conflicting VG info %s %s.", dev_name(info->dev), vgid_dashed, vgname);
+			return_0;
+		}
+	}
+
+	if (!vginfo) {
 		/*
 	 	 * Create a vginfo struct for this VG and put the vginfo
 	 	 * into the hash table.
diff --git a/test/shell/duplicate-vgid.sh b/test/shell/duplicate-vgid.sh
new file mode 100644
index 000000000..12163c2f0
--- /dev/null
+++ b/test/shell/duplicate-vgid.sh
@@ -0,0 +1,52 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 2
+
+vgcreate $vg1 "$dev1"
+vgchange --setautoactivation n $vg1
+UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
+lvcreate -l1 -an -n $lv1 $vg1
+dd if="$dev1" of="$dev2" bs=1M count=1
+aux disable_dev "$dev1"
+vgrename $vg1 $vg2
+pvchange -u "$dev2"
+aux enable_dev "$dev1"
+
+vgs -o+uuid |tee out
+grep $vg1 out | tee out1
+grep $UUID1 out1
+grep $vg2 out | tee out2
+grep $UUID1 out2
+
+vgs $vg1
+vgs $vg2
+lvs $vg1/$lv1
+lvs $vg2/$lv1
+
+lvremove $vg1/$lv1
+lvremove $vg2/$lv1
+
+lvcreate -l1 -an -n $lv2 $vg1
+lvcreate -l1 -an -n $lv3 $vg2
+
+vgchange -u $vg2
+
+vgs -o uuid $vg1 |tee out
+grep $UUID1 out
+
+vgs -o uuid $vg2 |tee out
+not grep $UUID1 out
+
+vgremove -ff $vg1
+vgremove -ff $vg2


