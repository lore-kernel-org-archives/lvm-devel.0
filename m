From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Jan 2022 22:06:36 +0000 (GMT)
Subject: main - Revert "handle duplicate vgids"
Message-ID: <20220111220636.3B7143858029@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7502f78678db7c7701e543a0a7267e050850ba53
Commit:        7502f78678db7c7701e543a0a7267e050850ba53
Parent:        bd2baeaaa67da3885df9f06700565dc201c82861
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 11 16:03:07 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 11 16:04:51 2022 -0600

Revert "handle duplicate vgids"

This reverts commit bd2baeaaa67da3885df9f06700565dc201c82861.

This commit broke vgrename because vgrename relies on old bugs
in lvmcache_update_vg_from_write and lvmcache_update_vgname
which need to be fixed first.
---
 lib/cache/lvmcache.c         | 20 ++++-------------
 test/shell/duplicate-vgid.sh | 52 --------------------------------------------
 2 files changed, 4 insertions(+), 68 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9c1619b7e..c5359f3c5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -354,11 +354,9 @@ static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vg
 	if (vgid_arg) {
 		if ((vginfo = dm_hash_lookup(_vgid_hash, vgid))) {
 			if (vgname && strcmp(vginfo->vgname, vgname)) {
-				log_warn("WARNING: lookup found duplicate VGID %s for VGs %s and %s.", vgid, vginfo->vgname, vgname);
-				if ((vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
-					if (!memcmp(vginfo->vgid, vgid, ID_LEN))
-						return vginfo;
-				}
+				/* should never happen */
+				log_error(INTERNAL_ERROR "vginfo_lookup vgid %s has two names %s %s",
+					  vgid, vginfo->vgname, vgname);
 				return NULL;
 			}
 			return vginfo;
@@ -1886,17 +1884,7 @@ static int _lvmcache_update_vgname(struct cmd_context *cmd,
 
 	_drop_vginfo(info, info->vginfo);
 
-	vginfo = lvmcache_vginfo_from_vgid(vgid);
-	if (vginfo && strcmp(vginfo->vgname, vgname)) {
-		log_warn("WARNING: fix duplicate VGID %s for VGs %s and %s (see vgchange -u).", vgid_dashed, vgname, vginfo->vgname);
-		vginfo = lvmcache_vginfo_from_vgname(vgname, NULL);
-		if (vginfo && memcmp(vginfo->vgid, vgid, ID_LEN)) {
-			log_error("Ignoring %s with conflicting VG info %s %s.", dev_name(info->dev), vgid_dashed, vgname);
-			return_0;
-		}
-	}
-
-	if (!vginfo) {
+	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid))) {
 		/*
 	 	 * Create a vginfo struct for this VG and put the vginfo
 	 	 * into the hash table.
diff --git a/test/shell/duplicate-vgid.sh b/test/shell/duplicate-vgid.sh
deleted file mode 100644
index 12163c2f0..000000000
--- a/test/shell/duplicate-vgid.sh
+++ /dev/null
@@ -1,52 +0,0 @@
-#!/usr/bin/env bash
-
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-
-SKIP_WITH_LVMLOCKD=1
-SKIP_WITH_LVMPOLLD=1
-
-. lib/inittest
-
-aux prepare_devs 2
-
-vgcreate $vg1 "$dev1"
-vgchange --setautoactivation n $vg1
-UUID1=$(vgs --noheading -o vg_uuid $vg1 | xargs)
-lvcreate -l1 -an -n $lv1 $vg1
-dd if="$dev1" of="$dev2" bs=1M count=1
-aux disable_dev "$dev1"
-vgrename $vg1 $vg2
-pvchange -u "$dev2"
-aux enable_dev "$dev1"
-
-vgs -o+uuid |tee out
-grep $vg1 out | tee out1
-grep $UUID1 out1
-grep $vg2 out | tee out2
-grep $UUID1 out2
-
-vgs $vg1
-vgs $vg2
-lvs $vg1/$lv1
-lvs $vg2/$lv1
-
-lvremove $vg1/$lv1
-lvremove $vg2/$lv1
-
-lvcreate -l1 -an -n $lv2 $vg1
-lvcreate -l1 -an -n $lv3 $vg2
-
-vgchange -u $vg2
-
-vgs -o uuid $vg1 |tee out
-grep $UUID1 out
-
-vgs -o uuid $vg2 |tee out
-not grep $UUID1 out
-
-vgremove -ff $vg1
-vgremove -ff $vg2


