From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:09 +0000 (UTC)
Subject: master - libdm: support newer thin pool status parameters
Message-ID: <20130204180809.0FBA93523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2eae42c0e3553fa13b8bc8f25b9c87fb2554861
Commit:        d2eae42c0e3553fa13b8bc8f25b9c87fb2554861
Parent:        c1becaefe5792a3cd9484e76bb8738f6082a1249
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 10 10:23:17 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:01:10 2013 +0100

libdm: support newer thin pool status parameters

Support read_only and discards information.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    8 ++++++++
 libdm/libdm-deptree.c |   15 +++++++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2b820e1..0052e5a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Extend support for status info of thin pool target.
   Fix segfault for truncated string token in config file after the first '"'.
   Close open dmeventd FIFO file descriptors on exec (FD_CLOEXEC).
   Fix resource leak in error path of dmeventd's umount of thin volume.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index eaa68e9..458d642 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -279,6 +279,12 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 /*
  * Parse params from STATUS call for thin_pool target
  */
+typedef enum {
+	DM_THIN_DISCARDS_IGNORE,
+	DM_THIN_DISCARDS_NO_PASSDOWN,
+	DM_THIN_DISCARDS_PASSDOWN
+} dm_thin_discards_t;
+
 struct dm_status_thin_pool {
 	uint64_t transaction_id;
 	uint64_t used_metadata_blocks;
@@ -286,6 +292,8 @@ struct dm_status_thin_pool {
 	uint64_t used_data_blocks;
 	uint64_t total_data_blocks;
 	uint64_t held_metadata_root;
+	uint32_t read_only;
+	dm_thin_discards_t discards;
 };
 
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index de4958e..6a73859 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3295,6 +3295,7 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 			    struct dm_status_thin_pool **status)
 {
 	struct dm_status_thin_pool *s;
+	int pos;
 
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
 		log_error("Failed to allocate thin_pool status structure.");
@@ -3302,16 +3303,26 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 	}
 
 	/* FIXME: add support for held metadata root */
-	if (sscanf(params, "%" PRIu64 " %" PRIu64 "/%" PRIu64 " %" PRIu64 "/%" PRIu64,
+	if (sscanf(params, "%" PRIu64 " %" PRIu64 "/%" PRIu64 " %" PRIu64 "/%" PRIu64 "%n",
 		   &s->transaction_id,
 		   &s->used_metadata_blocks,
 		   &s->total_metadata_blocks,
 		   &s->used_data_blocks,
-		   &s->total_data_blocks) != 5) {
+		   &s->total_data_blocks, &pos) < 5) {
 		log_error("Failed to parse thin pool params: %s.", params);
 		return 0;
 	}
 
+	/* New status flags */
+	if (strstr(params + pos, "no_discard_passdown"))
+		s->discards = DM_THIN_DISCARDS_NO_PASSDOWN;
+	else if (strstr(params + pos, "ignore_discard"))
+		s->discards = DM_THIN_DISCARDS_IGNORE;
+	else /* default discard_passdown */
+		s->discards = DM_THIN_DISCARDS_PASSDOWN;
+
+	s->read_only = (strstr(params + pos, "ro ")) ? 1 : 0;
+
 	*status = s;
 
 	return 1;


