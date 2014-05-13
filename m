From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 May 2014 09:04:37 +0000 (UTC)
Subject: master - cleanup: improve error message
Message-ID: <20140513090437.5A4FE60FFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85cf5a23d265c10af7e69b5f85e06e75105d8f14
Commit:        85cf5a23d265c10af7e69b5f85e06e75105d8f14
Parent:        7b766b064837110a09d448376ea61af174260ae7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 13 10:33:17 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 13 10:33:17 2014 +0200

cleanup: improve error message

Update impossile to happen error message.
---
 lib/config/config.c       |    2 +-
 lib/metadata/thin_manip.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 1a9f636..04f917d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1767,7 +1767,7 @@ int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, str
 	uint32_t chunk_size;
 
 	if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
-		log_error(INTERNAL_ERROR "Cannot find profile.");
+		log_error(INTERNAL_ERROR "Cannot find configuration.");
 		return 0;
 	}
 
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index c1c90b4..cccd244 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -376,7 +376,7 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
 		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
 			if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
-				log_error(INTERNAL_ERROR "Could not find profile.");
+				log_error(INTERNAL_ERROR "Could not find configuration.");
 				return 0;
 			}
 			if (!strcasecmp(str, "generic"))
@@ -401,7 +401,7 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
 
 	if (!(passed_args & PASS_ARG_DISCARDS)) {
 		if (!(str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile))) {
-			log_error(INTERNAL_ERROR "Could not find profile.");
+			log_error(INTERNAL_ERROR "Could not find configuration.");
 			return 0;
 		}
 		if (!get_pool_discards(str, discards))


