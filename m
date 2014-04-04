From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:38:14 +0000 (UTC)
Subject: master - clvmd: Update new remove_info INTERNAL_ERRORS.
Message-ID: <20140404003814.151E1602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c16c1a9f7071ab91e0f14f42d172adfe0db1e9cf
Commit:        c16c1a9f7071ab91e0f14f42d172adfe0db1e9cf
Parent:        12ddaa5f104a35df777b97802d9025ceaaadd0db
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:37:43 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:37:43 2014 +0100

clvmd: Update new remove_info INTERNAL_ERRORS.

---
 daemons/clvmd/lvm-functions.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 4ce0fcc..f4fb7fd 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -180,15 +180,17 @@ static int insert_info(const char *resource, struct lv_info *lvi)
 
 static void remove_info(const char *resource)
 {
+	int num_open;
+
 	pthread_mutex_lock(&lv_hash_lock);
 	dm_hash_remove(lv_hash, resource);
 
 	/* When last lock is remove, validate there are not left opened devices */
 	if (!dm_hash_get_first(lv_hash)) {
-		if (dev_cache_check_for_open_devices())
-			log_error(INTERNAL_ERROR "Nothing is locked however there are still opened devices.");
 		if (critical_section())
-			log_error(INTERNAL_ERROR "Nothing is locked however clvmd is left in critical section.");
+			log_error(INTERNAL_ERROR "No volumes are locked however clvmd is in activation mode critical section.");
+		if ((num_open = dev_cache_check_for_open_devices()))
+			log_error(INTERNAL_ERROR "No volumes are locked however %d devices are still open.", num_open);
 	}
 
 	pthread_mutex_unlock(&lv_hash_lock);


