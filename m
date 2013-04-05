From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Apr 2013 12:16:17 +0000 (UTC)
Subject: master - libdm: validate params for NULL
Message-ID: <20130405121618.0EE4435ED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fd0242a0af7b473f545ab89defcd0f56bcb9753
Commit:        3fd0242a0af7b473f545ab89defcd0f56bcb9753
Parent:        72921d79225bb822f156212177253ac2a0cb8082
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 2 15:01:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 5 14:13:12 2013 +0200

libdm: validate params for NULL

Validate passed params and report error
instead of dereferencing NULL passed argument.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |   19 ++++++++++++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 98ffa6f..eff6bd6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Validate passed params to dm_get_status_raid/thin/thin_pool(). 
   Fix 'dmsetup splitname -o' to not fail if used without '-c' switch (1.02.68).
   Add dm_config_write_{node_out/one_node_out} for enhanced config output.
   Add dm_config_value_is_bool to check for boolean value in supported formats.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e702a25..8292791 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2877,11 +2877,14 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		       struct dm_status_raid **status)
 {
 	int dev_count;
-	const char *p = params;
+	const char *p;
 	struct dm_status_raid *s;
 
-	if (!(p = strchr(p, ' ')))
-		return_0;
+	if (!params || !(p = strchr(params, ' '))) {
+		log_error("Failed to parse invalid raid params.");
+		return 0;
+	}
+
 	p++;
 
 	if (sscanf(p, "%d", &dev_count) != 1)
@@ -3318,6 +3321,11 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 	struct dm_status_thin_pool *s;
 	int pos;
 
+	if (!params) {
+		log_error("Failed to parse invalid thin pool params.");
+		return 0;
+	}
+
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
 		log_error("Failed to allocate thin_pool status structure.");
 		return 0;
@@ -3354,6 +3362,11 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 {
 	struct dm_status_thin *s;
 
+	if (!params) {
+		log_error("Failed to parse invalid thin params.");
+		return 0;
+	}
+
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin)))) {
 		log_error("Failed to allocate thin status structure.");
 		return 0;


