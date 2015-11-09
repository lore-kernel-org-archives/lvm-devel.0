From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:31 +0000 (UTC)
Subject: master - libdm: add test for dm_task_get_message_response()
Message-ID: <20151109092831.0654960CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cadc1c87e4f1f6cede3895a7f7f28f37eaf9648
Commit:        3cadc1c87e4f1f6cede3895a7f7f28f37eaf9648
Parent:        84303dc17aeca9773d5644e4beccc267ab7a3153
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:50:46 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

libdm: add test for  dm_task_get_message_response()

Coverity notices dm_task_get_message_response() result should be
checked for NULL which should not be passed to dm_pool_strdup().
---
 WHATS_NEW_DM        |    1 +
 libdm/libdm-stats.c |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c735194..795776b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.111 - 
 ====================================
+  Test dm_task_get_message_response for !NULL in dm_stats_print_region().
   Add checks for failing dm_stats_create() in dmsetup.
   Add missing fifo close when failed to initialize client connection.
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 43479d9..505b062 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1259,6 +1259,7 @@ char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
 {
 	char *resp = NULL;
 	struct dm_task *dmt = NULL;
+	const char *response;
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -1269,7 +1270,10 @@ char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
 	if (!dmt)
 		return_0;
 
-	resp = dm_pool_strdup(dms->mem, dm_task_get_message_response(dmt));
+	if (!(response = dm_task_get_message_response(dmt)))
+		return_0;
+
+	resp = dm_pool_strdup(dms->mem, response);
 	dm_task_destroy(dmt);
 
 	if (!resp)


