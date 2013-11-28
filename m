From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:48:59 +0000 (UTC)
Subject: master - cleanup: use matching signed types
Message-ID: <20131128114859.664D460F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50e1fad86a5ca85965222d2ba9b8a7076d07cbbc
Commit:        50e1fad86a5ca85965222d2ba9b8a7076d07cbbc
Parent:        c6cfd7b2b93645a96db74f90d57bc5031704c298
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 25 13:42:30 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:47:51 2013 +0100

cleanup: use matching signed types

---
 daemons/clvmd/clvmd.c         |    2 +-
 lib/metadata/mirror.c         |    2 +-
 libdaemon/server/daemon-log.c |    4 ++--
 tools/lvconvert.c             |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index d57c0fd..fc8cf6e 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1095,7 +1095,7 @@ static int verify_message(char *buf, int len)
 {
 	struct clvm_header *h = (struct clvm_header *)buf;
 
-	if (len < sizeof(struct clvm_header)) {
+	if (len < (int)sizeof(struct clvm_header)) {
 		log_error("verify_message short len %d", len);
 		return -1;
 	}
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index a2b2feb..6fc7674 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -847,7 +847,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	uint32_t new_area_count = mirrored_seg->area_count;
 	struct lv_list *lvl;
 	struct dm_list tmp_orphan_lvs;
-	int orig_removed = num_removed;
+	uint32_t orig_removed = num_removed;
 
 	if (removed)
 		*removed = 0;
diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index c9e133c..91900af 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -51,7 +51,7 @@ struct backend backend[] = {
 void daemon_log(log_state *s, int type, const char *message) {
 	int i = 0;
 	while ( backend[i].id ) {
-		if ( (s->log_config[type] & backend[i].id) == backend[i].id )
+		if ((int)(s->log_config[type] & backend[i].id) == backend[i].id )
 			backend[i].log( s, &s->backend_state[i], type, message );
 		++ i;
 	}
@@ -60,7 +60,7 @@ void daemon_log(log_state *s, int type, const char *message) {
 static int _type_interesting(log_state *s, int type) {
 	int i = 0;
 	while ( backend[i].id ) {
-		if ( (s->log_config[type] & backend[i].id) == backend[i].id )
+		if ((int)(s->log_config[type] & backend[i].id) == backend[i].id )
 			return 1;
 		++ i;
 	}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9a542a6..6f81356 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -958,7 +958,7 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
  *  1  = 'disk'
  *  2+ = 'mirrored'
  */
-static int _get_log_count(struct logical_volume *lv)
+static uint32_t _get_log_count(struct logical_volume *lv)
 {
 	struct logical_volume *log_lv;
 
@@ -1434,7 +1434,7 @@ int mirror_remove_missing(struct cmd_context *cmd,
 	if (!(failed_pvs = _failed_pv_list(lv->vg)))
 		return_0;
 
-        if (force && _failed_mirrors_count(lv) == lv_mirror_count(lv)) {
+	if (force && _failed_mirrors_count(lv) == (int)lv_mirror_count(lv)) {
 		log_error("No usable images left in %s.", lv->name);
 		return lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0);
         }


