From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:05 +0100
Subject: [PATCH 01/29] Cleanup remove test for NULL
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <e0764574ca6db50ef95e464198f8d4d8fef19e28.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dm_free test for NULL itself.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-common.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index b86739a..2dfa28f 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -250,10 +250,8 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 	char path[PATH_MAX];
 	struct stat st1, st2;
 
-	if (dmt->dev_name) {
-		dm_free(dmt->dev_name);
-		dmt->dev_name = NULL;
-	}
+	dm_free(dmt->dev_name);
+	dmt->dev_name = NULL;
 
 	/*
 	 * Path supplied for existing device?
@@ -292,8 +290,7 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 
 	if (strlen(name) >= DM_NAME_LEN) {
 		log_error("Name \"%s\" too long", name);
-		if (new_name)
-			dm_free(new_name);
+		dm_free(new_name);
 		return 0;
 	}
 
@@ -309,10 +306,7 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 
 int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 {
-	if (dmt->uuid) {
-		dm_free(dmt->uuid);
-		dmt->uuid = NULL;
-	}
+	dm_free(dmt->uuid);
 
 	if (!(dmt->uuid = dm_strdup(uuid))) {
 		log_error("dm_task_set_uuid: strdup(%s) failed", uuid);
-- 
1.7.3.2


