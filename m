From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 22 Jun 2017 14:18:32 -0400
Subject: master - debug: show message only when origin_only was set
Message-ID: <201706221818.v5MIIWq5006629@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=41c10034aa0db3c63f18ff78b64af3a799c154a1
Commit:        41c10034aa0db3c63f18ff78b64af3a799c154a1
Parent:        58e075f5fb12d8bce4ebb1c19c9f20b10d984e57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 22 17:14:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 22 20:17:20 2017 +0200

debug: show message only when origin_only was set

---
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/raid_manip.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c431868..1a584f2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6372,7 +6372,7 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 	if (!vg_write(vg))
 		return_0;
 
-	if (lock_lv != lv) {
+	if (origin_only && (lock_lv != lv)) {
 		log_debug_activation("Dropping origin_only for %s as lock holds %s",
 				     display_lvname(lv), display_lvname(lock_lv));
 		origin_only = 0;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 66fc2bd..08347f9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -557,7 +557,7 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	va_start(ap, origin_only);
 	removal_lvs = va_arg(ap, struct dm_list *);
 
-	if (lock_lv != lv) {
+	if (origin_only && (lock_lv != lv)) {
 		log_debug_activation("Dropping origin_only for %s as lock holds %s",
 				     display_lvname(lv), display_lvname(lock_lv));
 		origin_only = 0;
@@ -649,7 +649,7 @@ static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only
 	struct lv_list *lvl;
 	int r;
 
-	if (lock_lv != lv) {
+	if (origin_only && (lock_lv != lv)) {
 		log_debug_activation("Dropping origin_only for %s as lock holds %s",
 				     display_lvname(lv), display_lvname(lock_lv));
 		origin_only = 0;
@@ -2120,7 +2120,7 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 	const struct logical_volume *lock_lv = lv_lock_holder(lv);
 	int r = 1;
 
-	if (lock_lv != lv) {
+	if (origin_only && (lock_lv != lv)) {
 		log_debug_activation("Dropping origin_only for %s as lock holds %s",
 				     display_lvname(lv), display_lvname(lock_lv));
 		origin_only = 0;


