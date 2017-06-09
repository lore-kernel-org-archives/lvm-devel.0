From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 07:04:49 -0400
Subject: master - cache: lvcreate --cachepool checks for cache pool
Message-ID: <201706091104.v59B4n3u003837@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3ef051e0637ac7f72ab245342e5a29394071c24
Commit:        b3ef051e0637ac7f72ab245342e5a29394071c24
Parent:        f91ea96b4f221894008d196c1f87b93527c51311
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 10:59:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 10:59:37 2017 +0200

cache: lvcreate --cachepool checks for cache pool

Code path missed validation of lvcreate --cachepool argument.
If the non cache-pool LV was passed in, code has still continued
further work and failed later on internal error.  Validate this
condition at right place now.
---
 WHATS_NEW                    |    1 +
 test/shell/lvcreate-cache.sh |    6 ++++++
 tools/lvcreate.c             |    7 +++++++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fcf3148..cdd401e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Improve lvcreate --cachepool arg validation.
   Limit maximal size of thin-pool for specific chunk size.
   Print a warning about in-use PVs with no VG using them.
   Disable automatic clearing of PVs that look like in-use orphans.
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index faa78b2..410e105 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -26,6 +26,7 @@ aux prepare_vg 5 80000
 
 aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
 
+
 #######################
 # Cache_Pool creation #
 #######################
@@ -62,6 +63,11 @@ grep "No command with matching syntax recognised" err
 # Check nothing has been created yet
 check vg_field $vg lv_count 0
 
+# Checks that argument passed with --cachepool is really a cache-pool
+lvcreate -an -l 1 -n $lv1 $vg
+# Hint: nice way to 'tee' only stderr.log so we can check it's log_error()
+fail lvcreate -L10 --cachepool $vg/$lv1 2> >(tee -a stderr.log >&2)
+grep "not a cache pool" stderr.log
 
 # With --type cache-pool we are clear which segtype has to be created
 lvcreate -l 1 --type cache-pool $vg/pool1
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e83c130..f464896 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1193,6 +1193,13 @@ static int _determine_cache_argument(struct volume_group *vg,
 		lp->create_pool = 0;
 		lp->origin_name = NULL;
 	} else if (lv) {
+		if (arg_is_set(cmd, cachepool_ARG)) {
+			/* Argument of --cachepool has to be a cache-pool */
+			log_error("Logical volume %s is not a cache pool.",
+				  display_lvname(lv));
+			return 0;
+		}
+
 		/* Origin exists, create cache pool volume */
 		if (!validate_lv_cache_create_origin(lv))
 			return_0;


