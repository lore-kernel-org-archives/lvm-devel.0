From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jul 2017 16:01:20 -0400
Subject: master - lvmlockd: miss adopt orphaned resources
Message-ID: <201707072001.v67K1KTp015469@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bffae6c9855033a22893b28a79d5e7952504b95e
Commit:        bffae6c9855033a22893b28a79d5e7952504b95e
Parent:        3797f47ecf23c41d4476e2cce0f210b48b32923d
Author:        Huan Zhang <zhanghuan@chinac.com>
AuthorDate:    Fri Jul 7 14:53:16 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 7 14:58:14 2017 -0500

lvmlockd: miss adopt orphaned resources

1. dm_uuid is 68 byte length, but buf is 64 which
   will cause miss match uuid from lv lock manager
2. no lv lock_type path in dm config, use lock_args instead

Signed-off-by: Zhang Huan <zhanghuan@chinac.com>
---
 daemons/lvmlockd/lvmlockd-core.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 4d96e67..b6f3df9 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4907,14 +4907,10 @@ static int get_lockd_vgs(struct list_head *vg_lockd)
 				continue;
 
 			for (lv_cn = md_cn->child; lv_cn; lv_cn = lv_cn->sib) {
-				snprintf(find_str_path, PATH_MAX, "%s/lock_type", lv_cn->key);
-				lock_type = dm_config_find_str(lv_cn, find_str_path, NULL);
-
-				if (!lock_type)
-					continue;
-
 				snprintf(find_str_path, PATH_MAX, "%s/lock_args", lv_cn->key);
 				lock_args = dm_config_find_str(lv_cn, find_str_path, NULL);
+				if (!lock_args)
+					continue;
 
 				snprintf(find_str_path, PATH_MAX, "%s/id", lv_cn->key);
 				lv_uuid = dm_config_find_str(lv_cn, find_str_path, NULL);
@@ -4960,7 +4956,7 @@ out:
 	return rv;
 }
 
-static char _dm_uuid[64];
+static char _dm_uuid[72];
 
 static char *get_dm_uuid(char *dm_name)
 {


