From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 14 Jan 2014 03:48:41 +0000 (UTC)
Subject: master - lvmcache: Invalidate cached VG if PV is orphaned.
Message-ID: <20140114034841.E58B560623@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c2b4c37e72b74553125664364efcda0e0758bf7
Commit:        4c2b4c37e72b74553125664364efcda0e0758bf7
Parent:        9c445f3c2c1553ff1e9f97c2302344736e7f35e8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 14 02:57:03 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 14 02:57:03 2014 +0000

lvmcache: Invalidate cached VG if PV is orphaned.

If a PV in an existing VG becomes orphaned (with 'pvcreate -ff', for
example) the VG struct cached against its vginfo must be invalidated.
This is because the struct device it references no longer contains
the PV label so becomes incorrect.

This triggers the error:
  Internal error: PV $dev unexpectedly not in cache.
when the PV from the cached VG metadata is subsequently looked up
in the cache.

Bug introduced in 2.02.87 by commit 7ad0d47c3c93053c07c45161dbdbc0798ac7e2f6
("Cache and share generated VG structs").

Before:

lvm> pvs
  PV         VG   Fmt  Attr PSize  PFree
  /dev/loop3 vg12 lvm2 a--  28.00m 28.00m
  /dev/loop4 vg12 lvm2 a--  28.00m 28.00m
lvm> pvcreate -ff /dev/loop3
Really INITIALIZE physical volume "/dev/loop3" of volume group "vg12" [y/n]? y
  WARNING: Forcing physical volume creation on /dev/loop3 of volume group "vg12"
  Physical volume "/dev/loop3" successfully created
lvm> pvs
  Internal error: PV /dev/loop3 unexpectedly not in cache.
  PV         VG   Fmt  Attr PSize  PFree
  /dev/loop3 vg12 lvm2 a--  28.00m 28.00m
  /dev/loop3      lvm2 a--  32.00m 32.00m
  /dev/loop4 vg12 lvm2 a--  28.00m 28.00m

After:
lvm> pvs
  PV         VG   Fmt  Attr PSize  PFree
  /dev/loop3 vg12 lvm2 a--  28.00m 28.00m
  /dev/loop4 vg12 lvm2 a--  28.00m 28.00m
lvm> pvcreate -ff /dev/loop3
Really INITIALIZE physical volume "/dev/loop3" of volume group "vg12" [y/n]? y
  WARNING: Forcing physical volume creation on /dev/loop3 of volume group "vg12"
  Physical volume "/dev/loop3" successfully created
lvm> pvs
  PV             VG   Fmt  Attr PSize  PFree
  /dev/loop3          lvm2 a--  32.00m 32.00m
  /dev/loop4     vg12 lvm2 a--  28.00m 28.00m
  unknown device vg12 lvm2 a-m  28.00m 28.00m
---
 WHATS_NEW            |    2 ++
 lib/cache/lvmcache.c |   12 +++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1dac25e..12845ab 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.105 -
 =====================================
+  Invalidate cached VG struct after a PV in it gets orphaned. (2.02.87)
+  Mark pool format metadata as FMT_OBSOLETE.
   Use major:minor in lvm2-pvscan at .service for proper global_filter application.
   Syntax and spelling fixes in some man pages.
   Dependency scan counts with snapshots and external origins.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 770a1b3..6719e99 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -64,6 +64,7 @@ struct lvmcache_vginfo {
 	unsigned holders;
 	unsigned vg_use_count;	/* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
+	unsigned cached_vg_invalidated;	/* Signal to regenerate cached_vg */
 };
 
 static struct dm_hash_table *_pvid_hash = NULL;
@@ -763,9 +764,11 @@ struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname
 		return NULL;
 
 	/* Use already-cached VG struct when available */
-	if ((vg = vginfo->cached_vg))
+	if ((vg = vginfo->cached_vg) && !vginfo->cached_vg_invalidated)
 		goto out;
 
+	release_vg(vginfo->cached_vg);
+
 	fic.type = FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
@@ -785,6 +788,7 @@ struct volume_group *lvmcache_get_vg(struct cmd_context *cmd, const char *vgname
 	vginfo->cached_vg = vg;
 	vginfo->holders = 1;
 	vginfo->vg_use_count = 0;
+	vginfo->cached_vg_invalidated = 0;
 	vg->vginfo = vginfo;
 
 	if (!dm_pool_lock(vg->vgmem, detect_internal_vg_cache_corruption()))
@@ -1407,6 +1411,12 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 	    !is_orphan_vg(info->vginfo->vgname) && critical_section())
 		return 1;
 
+	/* If making a PV into an orphan, any cached VG metadata may become
+	 * invalid, incorrectly still referencing device structs.
+	 * (Example: pvcreate -ff) */
+	if (is_orphan_vg(vgname) && info->vginfo && !is_orphan_vg(info->vginfo->vgname))
+		info->vginfo->cached_vg_invalidated = 1;
+
 	/* If moving PV from orphan to real VG, always mark it valid */
 	if (!is_orphan_vg(vgname))
 		info->status &= ~CACHE_INVALID;


