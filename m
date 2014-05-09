From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:28 +0000 (UTC)
Subject: dev-prajnoha-selout - coverity: check for profile
Message-ID: <20140509065628.CD70D60774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8042f33d0ee7f71952d65f2cc408775fa440c8a
Commit:        a8042f33d0ee7f71952d65f2cc408775fa440c8a
Parent:        48a8cf28f751156471a3fc65650fc600cd24833c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 10:52:00 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:15:52 2014 +0200

coverity: check for profile

Ensure str is not NULL for analyzer.
---
 lib/config/config.c       |    5 ++++-
 lib/metadata/thin_manip.c |   10 ++++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index a751d3e..1a9f636 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1766,7 +1766,10 @@ int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, str
 	const char *str;
 	uint32_t chunk_size;
 
-	str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
+	if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
+		log_error(INTERNAL_ERROR "Cannot find profile.");
+		return 0;
+	}
 
 	if (!strcasecmp(str, "generic"))
 		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 78231a2..c1c90b4 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -375,7 +375,10 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
-			str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
+			if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
+				log_error(INTERNAL_ERROR "Could not find profile.");
+				return 0;
+			}
 			if (!strcasecmp(str, "generic"))
 				*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
 			else if (!strcasecmp(str, "performance"))
@@ -397,7 +400,10 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 	}
 
 	if (!(passed_args & PASS_ARG_DISCARDS)) {
-		str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
+		if (!(str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile))) {
+			log_error(INTERNAL_ERROR "Could not find profile.");
+			return 0;
+		}
 		if (!get_pool_discards(str, discards))
 			return_0;
 	}


