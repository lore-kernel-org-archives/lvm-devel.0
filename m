From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:04 -0500
Subject: master - thin: getting default chunk_size from single place
Message-ID: <201703101835.v2AIZ4X3017902@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=375e4bb3dae71bad55359f22aec6061c0b5f4296
Commit:        375e4bb3dae71bad55359f22aec6061c0b5f4296
Parent:        50441f243387bb5fb0e27ebc7a859f5bdcbc4c60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 1 11:23:26 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

thin: getting default chunk_size from single place

Basically code moving operation to have a single place resolving
thin_pool_chunk_size_policy.

Supported are generic & performance profiles.

Function is now shared between thin manipulation code and configuration
_CFG logic to obtain defaults and handle correct reporting upward coding
stack.
---
 lib/config/config.c              |   16 +++-----------
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/thin_manip.c        |   40 +++++++++++++++++++++++++------------
 3 files changed, 33 insertions(+), 25 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 3e30951..c62b4c3 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -2442,21 +2442,13 @@ const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_cont
 
 int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile)
 {
-	const char *str;
 	uint32_t chunk_size;
+	int chunk_size_calc_method;
 
-	if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
-		log_error(INTERNAL_ERROR "Cannot find configuration.");
-		return 0;
-	}
-
-	if (!strcasecmp(str, "generic"))
+	if (!get_default_allocation_thin_pool_chunk_size(cmd, profile, &chunk_size,
+							 &chunk_size_calc_method)) {
+		stack; /* Ignore this error, never happens... */
 		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
-	else if (!strcasecmp(str, "performance"))
-		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2;
-	else {
-		log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
-		return 0;
 	}
 
 	return (int) chunk_size;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9e1f4b6..dce2d44 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -859,6 +859,8 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 				  int passed_args, int *chunk_size_calc_method,
 				  uint32_t *chunk_size, thin_discards_t *discards,
 				  int *zero);
+int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct profile *profile,
+						uint32_t *chunk_size, int *chunk_size_calc_method);
 int update_thin_pool_params(const struct segment_type *segtype,
 			    struct volume_group *vg, unsigned attr,
 			    int passed_args, uint32_t pool_data_extents,
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 3e2a185..27daf6a 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -574,6 +574,30 @@ static size_t _estimate_chunk_size(uint64_t data_size, uint64_t metadata_size, i
 	return chunk_size;
 }
 
+int get_default_allocation_thin_pool_chunk_size(struct cmd_context *cmd, struct profile *profile,
+						uint32_t *chunk_size, int *chunk_size_calc_method)
+{
+	const char *str;
+
+	if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
+		log_error(INTERNAL_ERROR "Cannot find configuration.");
+		return 0;
+	}
+
+	if (!strcasecmp(str, "generic")) {
+		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE * 2;
+		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
+	} else if (!strcasecmp(str, "performance")) {
+		*chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE * 2;
+		*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE;
+	} else {
+		log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
+		return 0;
+	}
+
+	return 1;
+}
+
 int update_thin_pool_params(const struct segment_type *segtype,
 			    struct volume_group *vg,
 			    unsigned attr, int passed_args,
@@ -591,19 +615,9 @@ int update_thin_pool_params(const struct segment_type *segtype,
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
-			if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
-				log_error(INTERNAL_ERROR "Could not find configuration.");
-				return 0;
-			}
-			if (!strcasecmp(str, "generic"))
-				*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
-			else if (!strcasecmp(str, "performance"))
-				*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE;
-			else {
-				log_error("Thin pool chunk size calculation policy \"%s\" is unrecognised.", str);
-				return 0;
-			}
-			if (!(*chunk_size = get_default_allocation_thin_pool_chunk_size_CFG(cmd, profile)))
+			if (!get_default_allocation_thin_pool_chunk_size(cmd, profile,
+									 chunk_size,
+									 chunk_size_calc_method))
 				return_0;
 		}
 	}


