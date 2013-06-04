From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:06 +0000 (UTC)
Subject: dev-mornfall-activate - lv: fix typedef
Message-ID: <20130604192606.512126142A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d0cb0611e5e68fc4d865102f8339552a907ff4b
Commit:        3d0cb0611e5e68fc4d865102f8339552a907ff4b
Parent:        4741e449e66d19a0285ee1772e0d40da2fd8d5c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 16:02:43 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 16:02:43 2013 +0200

lv: fix typedef

Since older gcc is not accepting duplication of same typedef,
stay with predeclared enum type.
---
 lib/metadata/lv.c |    2 +-
 lib/metadata/lv.h |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 283b8c4..69b13fa 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -705,7 +705,7 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 }
 
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     activation_change_t activate)
+		     enum activation_change activate)
 {
 	if (activate == CHANGE_AN) {
 		log_verbose("Deactivating logical volume \"%s\"", lv->name);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index ed0d745..8e771a1 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -21,7 +21,6 @@ struct dm_list;
 struct lv_segment;
 struct replicator_device;
 enum activation_change;
-typedef enum activation_change activation_change_t;
 
 struct logical_volume {
 	union lvid lvid;
@@ -88,7 +87,7 @@ int lv_set_creation(struct logical_volume *lv,
 		    const char *hostname, uint64_t timestamp);
 const char *lv_layer(const struct logical_volume *lv);
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
-		     activation_change_t activate);
+		     enum activation_change activate);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 #endif /* _LVM_LV_H */


