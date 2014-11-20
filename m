From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:37:42 +0000 (UTC)
Subject: master - cache: check for internal error
Message-ID: <20141120153742.5EEF7609C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f2961f259ff990d3a21e8edac5f7caa564b0e2e
Commit:        9f2961f259ff990d3a21e8edac5f7caa564b0e2e
Parent:        e55c6999ae62506dd8798451bb95d7a3aa7da765
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 20 16:35:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 20 16:35:46 2014 +0100

cache: check for internal error

Don't try to duplicate NULL on internal error path.
---
 lib/metadata/lv.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index bf2d04e..fb1cd78 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -130,7 +130,12 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return dm_pool_strdup(mem, get_cache_pool_cachemode_name(seg));
+	const char *name = get_cache_pool_cachemode_name(seg);
+
+	if (!name)
+		return_NULL;
+
+	return dm_pool_strdup(mem, name);
 }
 
 #ifdef DMEVENTD


