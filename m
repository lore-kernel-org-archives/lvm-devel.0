From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:28 +0000 (UTC)
Subject: master - cleanup: malloc attributes
Message-ID: <20130205134728.64180A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d74ff2bf8313dae0cc27530eebf63be06a7bae6
Commit:        6d74ff2bf8313dae0cc27530eebf63be06a7bae6
Parent:        ddeb37f282caf053687d447cd7f52cb7d5a1f702
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 4 20:29:59 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:27:24 2013 +0100

cleanup: malloc attributes

---
 libdm/libdevmapper.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 458d642..b08a549 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -770,15 +770,15 @@ uint32_t dm_tree_get_cookie(struct dm_tree_node *node);
  *******************/
 
 void *dm_malloc_aux(size_t s, const char *file, int line)
-	__attribute__((malloc)) __attribute__((__warn_unused_result__));
+	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_malloc_aux_debug(size_t s, const char *file, int line)
 	__attribute__((__warn_unused_result__));
 void *dm_zalloc_aux(size_t s, const char *file, int line)
-	__attribute__((malloc)) __attribute__((__warn_unused_result__));
+	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void *dm_zalloc_aux_debug(size_t s, const char *file, int line)
 	__attribute__((__warn_unused_result__));
 char *dm_strdup_aux(const char *str, const char *file, int line)
-	__attribute__((malloc)) __attribute__((__warn_unused_result__));
+	__attribute__((__malloc__)) __attribute__((__warn_unused_result__));
 void dm_free_aux(void *p);
 void *dm_realloc_aux(void *p, unsigned int s, const char *file, int line)
 	__attribute__((__warn_unused_result__));


