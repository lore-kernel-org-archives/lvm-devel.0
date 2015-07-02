From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  2 Jul 2015 21:37:15 +0000 (UTC)
Subject: master - lockd: fix stub functions for LV locking
Message-ID: <20150702213715.3784C606DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e944a9c63561f6a6bb5690f9df14ba4ababb02b3
Commit:        e944a9c63561f6a6bb5690f9df14ba4ababb02b3
Parent:        fe70b03de2956b6493993990d9fb1cde3f41ebcd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 2 16:33:51 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 2 16:36:04 2015 -0500

lockd: fix stub functions for LV locking

The stub functions for lockd LV locking were returning
the wrong result when lvm was compiled without lvmlockd.
---
 lib/locking/lvmlockd.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 20cd7de..17c7222 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -203,19 +203,19 @@ static inline int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 static inline int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg,
 		  	struct logical_volume *lv, struct lvcreate_params *lp)
 {
-	return 0;
+	return 1;
 }
 
 static inline int lockd_init_lv_args(struct cmd_context *cmd, struct volume_group *vg,
 		       struct logical_volume *lv, const char *lock_type, const char **lock_args)
 {
-	return 0;
+	return 1;
 }
 
 static inline int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
 		  const char *lv_name, struct id *lv_id, const char *lock_args)
 {
-	return 0;
+	return 1;
 }
 
 static inline const char *lockd_running_lock_type(struct cmd_context *cmd)


