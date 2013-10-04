From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Oct 2013 10:32:47 +0000 (UTC)
Subject: master - thin: rename thin_pool_chunk_size_calculation -> ..size_policy and rename "default" policy to "generic"
Message-ID: <20131004103247.98BEE610BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cf0810d57a0c47173c4775a08dd728c452f8eb8
Commit:        8cf0810d57a0c47173c4775a08dd728c452f8eb8
Parent:        baf95bbff70bdd1474b678f37b840025295903ae
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 4 12:30:33 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 4 12:30:33 2013 +0200

thin: rename thin_pool_chunk_size_calculation -> ..size_policy and rename "default" policy to "generic"

Just to be consistent with existing naming we use.
---
 conf/example.conf.in             |    6 +++---
 lib/config/config_settings.h     |    2 +-
 lib/config/defaults.h            |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/thin_manip.c        |    6 +++---
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index f06b705..e0f8be8 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -252,9 +252,9 @@ allocation {
     # be placed on different PVs from the pool data.
     thin_pool_metadata_require_separate_pvs = 0
 
-    # Specify chunk size calculation method for thin pool volumes.
+    # Specify chunk size calculation policy for thin pool volumes.
     # Possible options are:
-    # "default"        - if thin_pool_chunk_size is defined, use it.
+    # "generic"        - if thin_pool_chunk_size is defined, use it.
     #                    Otherwise, calcucate the chunk size based on
     #                    estimation and device hints exposed in sysfs:
     #                    the minimum_io_size. The chunk size is always
@@ -265,7 +265,7 @@ allocation {
     # 			 performance based on device hints exposed in
     # 			 sysfs: the optimal_io_size. The chunk size is
     # 			 always at least 512KiB.
-    # thin_pool_chunk_size_calculation = "default"
+    # thin_pool_chunk_size_policy = "generic"
 
     # Specify the minimal chunk size (in KB) for thin pool volumes.
     # Use of the larger chunk size may improve perfomance for plain
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f7c1330..c935920 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -107,7 +107,7 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
-cfg(allocation_thin_pool_chunk_size_calculation_CFG, "thin_pool_chunk_size_calculation", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_CALCULATION, vsn(2, 2, 101), NULL)
+cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL)
 cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, 0, vsn(2, 2, 99), NULL)
 
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index cd3b5f9..fc2d4dc 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -71,7 +71,7 @@
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)	/* KB */
-#define DEFAULT_THIN_POOL_CHUNK_SIZE_CALCULATION "default"
+#define DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY "generic"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE 512 /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 71fe393..971f677 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -726,7 +726,7 @@ struct lvcreate_params {
 	int activation_skip; /* activation skip flags */
 	activation_change_t activate; /* non-snapshot, non-mirror */
 	thin_discards_t discards;     /* thin */
-#define THIN_CHUNK_SIZE_CALC_METHOD_DEFAULT 0x01
+#define THIN_CHUNK_SIZE_CALC_METHOD_GENERIC 0x01
 #define THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE 0x02
 	int thin_chunk_size_calc_method;
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index c71b971..f85696c 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -573,8 +573,8 @@ static int _get_pool_chunk_size_calc(const char *str,
 				     int *chunk_size_calc_method,
 				     uint32_t *chunk_size)
 {
-	if (!strcasecmp(str, "default")) {
-		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_DEFAULT;
+	if (!strcasecmp(str, "generic")) {
+		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
 		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
 	}
 	else if (!strcasecmp(str, "performance")) {
@@ -598,7 +598,7 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
-			str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_calculation_CFG, profile);
+			str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
 			if (!_get_pool_chunk_size_calc(str, chunk_size_calc_method, chunk_size))
 				return_0;
 		}


