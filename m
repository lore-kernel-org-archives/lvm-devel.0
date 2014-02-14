From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 14 Feb 2014 22:04:39 +0000 (UTC)
Subject: master - cache: Fix cache LV not being instantiated in kernel
Message-ID: <20140214220439.D1F0E6016A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa4812bf7b336cf1a301ec7218f905894422e61e
Commit:        fa4812bf7b336cf1a301ec7218f905894422e61e
Parent:        554159d519ba5c523d506785d61d10374456a020
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Feb 14 16:03:23 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Feb 14 16:04:31 2014 -0600

cache: Fix cache LV not being instantiated in kernel

When an origin exists and the 'lvcreate' command is used to create
a cache pool + cache LV, the table is loaded into the kernel but
never instantiated (suspend/resume was never called).  A user running
LVM commands would never know that the kernel did not have the
proper state unless they also ran the dmsetup 'table/status' command.
The solution is to suspend/resume the cache LV to make the loaded
tables become active.
---
 lib/metadata/lv_manip.c      |   20 +++++++++++++++++++-
 test/shell/lvcreate-cache.sh |    2 ++
 2 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d38dd7c..6b4c9a8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6282,7 +6282,25 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	if (lp->temporary)
 		lv->status |= LV_TEMPORARY;
 
-	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
+	if (lv_is_cache_type(lv)) {
+		if (!lv_is_active(lv)) {
+			if (!activate_lv_excl(cmd, lv)) {
+				log_error("Failed to activate pool %s.",
+					  lv->name);
+				goto deactivate_and_revert_new_lv;
+			}
+		} else {
+			if (!suspend_lv(cmd, lv)) {
+				log_error("Failed to suspend pool %s.",
+					  lv->name);
+				goto deactivate_and_revert_new_lv;
+			}
+			if (!resume_lv(cmd, lv)) {
+				log_error("Failed to resume pool %s.", lv->name);
+				goto deactivate_and_revert_new_lv;
+			}
+		}
+	} else if (lv_is_thin_pool(lv)) {
 		if (is_change_activating(lp->activate)) {
 			if (vg_is_clustered(lv->vg)) {
 				if (!activate_lv_excl(cmd, lv)) {
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 39f95c1..01e6f51 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -48,6 +48,7 @@ lvremove -ff $vg
 # Create cache_pool, then origin with cache, then remove all
 lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
+dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 lvremove -ff $vg
 
 # Create cache_pool, then origin with cache, then remove cache_pool/cache
@@ -75,6 +76,7 @@ lvremove -ff $vg/${lv}_cache_pool
 # Create origin, then cache_pool and cache
 lvcreate -l 2 -n $lv1 $vg
 lvcreate --type cache -l 1 $vg/$lv1
+dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 lvremove -ff $vg
 
 # Shorthand CLI (origin exists, create cache_pool and cache)


