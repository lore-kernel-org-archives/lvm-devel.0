From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:02 +0000 (UTC)
Subject: master - libdm: check for null from pool strdup
Message-ID: <20151116001702.1148E60645@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4288c9bdfa104bef1e31185da0b773924218f35
Commit:        d4288c9bdfa104bef1e31185da0b773924218f35
Parent:        422c7474ca97066ab92d145ac45bc4a9cd38e1b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 00:00:32 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:09 2015 +0100

libdm: check for null from pool strdup

Unlikely to happen, but Coverity shown we may have possible
derefer NULL pointer.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-string.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 795776b..5e9228a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.111 - 
 ====================================
+  Add missing check for allocation inside dm_split_lvm_name().
   Test dm_task_get_message_response for !NULL in dm_stats_print_region().
   Add checks for failing dm_stats_create() in dmsetup.
   Add missing fifo close when failed to initialize client connection.
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 587abfe..9132832 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -95,8 +95,10 @@ static char *_unquote(char *component)
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
-	if (mem)
-		*vgname = dm_pool_strdup(mem, dmname);
+	if (mem && !(*vgname = dm_pool_strdup(mem, dmname))) {
+		log_error("Failed to duplicate dmname.");
+		return 0;
+	}
 
 	if (!*vgname)
 		return 0;


