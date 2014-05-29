From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 May 2014 12:32:58 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: some remaining str_list_add -> dm_str_list_add renames
Message-ID: <20140529123258.51008602FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94509e38f29ebcd78f4e653846de50df0f2121b8
Commit:        94509e38f29ebcd78f4e653846de50df0f2121b8
Parent:        152c240f953b90ee6977e6ce20dfe36b0b8eb6ef
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 14:12:33 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 29 14:29:38 2014 +0200

report: select: some remaining str_list_add -> dm_str_list_add renames

---
 lib/cache_segtype/cache.c   |    2 +-
 lib/replicator/replicator.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index afe33b2..b3dac46 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -255,7 +255,7 @@ static int _modules_needed(struct dm_pool *mem,
 			   const struct lv_segment *seg __attribute__((unused)),
 			   struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, "cache")) {
+	if (!dm_str_list_add(mem, modules, "cache")) {
 		log_error("String list allocation failed for cache module.");
 		return 0;
 	}
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 4158edc..3932ead 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -394,10 +394,10 @@ static int _replicator_modules_needed(struct dm_pool *mem,
 				      const struct lv_segment *seg __attribute__((unused)),
 				      struct dm_list *modules)
 {
-	if (!str_list_add(mem, modules, REPLICATOR_MODULE))
+	if (!dm_str_list_add(mem, modules, REPLICATOR_MODULE))
 		return_0;
 
-	if (!str_list_add(mem, modules, REPLICATOR_DEV_MODULE))
+	if (!dm_str_list_add(mem, modules, REPLICATOR_DEV_MODULE))
 		return_0;
 
 	return 1;


