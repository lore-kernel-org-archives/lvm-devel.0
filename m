From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:44 +0000 (UTC)
Subject: master - dm: alloc always 8byte aligned
Message-ID: <20160211173944.06F6760DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0baf66a992fbac92fa2c30e9bb8e74a5535ff45a
Commit:        0baf66a992fbac92fa2c30e9bb8e74a5535ff45a
Parent:        f91622741f95713539b863338743eb217e0731c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 11 12:00:28 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:35:05 2016 +0100

dm: alloc always 8byte aligned

Fixing regression caused by 197b5e6dc7dd8ec161ebe43c97fd2ac8384b3433.
So the 'TODO' part now finally know the answer - there is 'sparc64'
architecture which imposes limitation to read 64b words only through
64b aligned address.

Since we never could know how is the user going to use the returned
pointer and the userusually expects it's aligned on the highest CPU
required alignement, preserve it also for char*.

Fixes: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=809685
Reported-by: Anatoly Pugachev <matorola@gmail.com>
---
 WHATS_NEW_DM    |    1 +
 libdm/mm/pool.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f54868f..693667b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.116 - 
 ====================================
+  Use fully aligned allocations for dm_pool_strdup/strndup() (1.02.64).
   Fix thin-pool table parameter feature order to match kernel output.
 
 Version 1.02.115 - 25th January 2016
diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
index ec6f1b8..c1cb61e 100644
--- a/libdm/mm/pool.c
+++ b/libdm/mm/pool.c
@@ -48,17 +48,18 @@ static size_t pagesize_mask = 0;
 
 char *dm_pool_strdup(struct dm_pool *p, const char *str)
 {
-	char *ret = dm_pool_alloc_aligned(p, strlen(str) + 1, 2);
+	size_t len = strlen(str) + 1;
+	char *ret = dm_pool_alloc(p, len);
 
 	if (ret)
-		strcpy(ret, str);
+		memcpy(ret, str, len);
 
 	return ret;
 }
 
 char *dm_pool_strndup(struct dm_pool *p, const char *str, size_t n)
 {
-	char *ret = dm_pool_alloc_aligned(p, n + 1, 2);
+	char *ret = dm_pool_alloc(p, n + 1);
 
 	if (ret) {
 		strncpy(ret, str, n);


