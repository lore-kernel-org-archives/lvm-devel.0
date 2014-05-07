From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  7 May 2014 12:19:09 +0000 (UTC)
Subject: master - cleanup: missed conversion to dm_malloc/free usage
Message-ID: <20140507121909.47850607BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9bccaf7ae40ca0d17e5d1b65f7c7aaf2d78eb2b9
Commit:        9bccaf7ae40ca0d17e5d1b65f7c7aaf2d78eb2b9
Parent:        d3e68c8a71c3bc36135d73cd8028cec56eca5cb2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 11:54:12 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:46 2014 +0200

cleanup: missed conversion to dm_malloc/free usage

Few missed unconverted dm_malloc/free calls.
---
 daemons/clvmd/lvm-functions.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e36e206..9fd71e8 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -236,7 +236,7 @@ void destroy_lvhash(void)
 		if ((status = sync_unlock(resource, lvi->lock_id)))
 			DEBUGLOG("unlock_all. unlock failed(%d): %s\n",
 				 status,  strerror(errno));
-		free(lvi);
+		dm_free(lvi);
 	}
 
 	dm_hash_destroy(lv_hash);
@@ -286,8 +286,7 @@ static int hold_lock(char *resource, int mode, int flags)
 				 strerror(errno));
 		errno = saved_errno;
 	} else {
-		lvi = malloc(sizeof(struct lv_info));
-		if (!lvi) {
+		if (!(lvi = dm_malloc(sizeof(struct lv_info)))) {
 			errno = ENOMEM;
 			return -1;
 		}
@@ -296,7 +295,7 @@ static int hold_lock(char *resource, int mode, int flags)
 		status = sync_lock(resource, mode, flags & ~LCKF_CONVERT, &lvi->lock_id);
 		saved_errno = errno;
 		if (status) {
-			free(lvi);
+			dm_free(lvi);
 			DEBUGLOG("hold_lock. lock at %d failed: %s\n", mode,
 				 strerror(errno));
 		} else
@@ -326,7 +325,7 @@ static int hold_unlock(char *resource)
 	saved_errno = errno;
 	if (!status) {
 		remove_info(resource);
-		free(lvi);
+		dm_free(lvi);
 	} else {
 		DEBUGLOG("hold_unlock. unlock failed(%d): %s\n", status,
 			 strerror(errno));


