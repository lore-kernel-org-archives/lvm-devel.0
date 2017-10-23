From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Oct 2017 06:07:23 -0400
Subject: master - lvcreate: skip checking for name restriction for caching
Message-ID: <201710231007.v9NA7NLL003935@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df3ff32fc012b1e881dd492c1e34a7d1020747b1
Commit:        df3ff32fc012b1e881dd492c1e34a7d1020747b1
Parent:        d6fcab900b5b33c55c7894c3f4a7cdd1dbb81c1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 23 11:36:51 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 23 12:01:15 2017 +0200

lvcreate: skip checking for name restriction for caching

lvcreate supports a 'conversion' when caching LV.
This normally worked fine, however in case passed LV was
thin-pool's data LV with suffix _tdata we have failed to early.

As the easiest fix looks dropping validation of name when
caching type is select - such name check will happen later
once the VG is opened again and properly detect if the LV
with protected name already exists and can be converted,
or will be rejected as ambigiuous operation requiring user
to specify  --type cache | --type cache-pool.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2f08468..d91900b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Allow lvcreate to be used for caching of _tdata LV.
   Avoid internal error when resizing cache type _tdata LV (not yet supported).
   Show original converted names when lvconverting LV to pool volume.
   Move lib code used only by liblvm into metadata-liblvm.c.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8aa16f2..ff57baf 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1425,7 +1425,7 @@ static int _check_pool_parameters(struct cmd_context *cmd,
 	if (lp->create_pool) {
 		/* Given pool name needs to follow restrictions for created LV */
 		if (lp->pool_name) {
-			if (!apply_lvname_restrictions(lp->pool_name))
+			if (!seg_is_cache(lp) && !apply_lvname_restrictions(lp->pool_name))
 				return_0;
 			/* We could check existance only when we have vg */
 			if (vg && find_lv(vg, lp->pool_name)) {


