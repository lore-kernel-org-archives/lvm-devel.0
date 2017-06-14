From: 张欢 <zhanghuan@chinac.com>
Date: Wed, 14 Jun 2017 20:07:52 +0800
Subject: [patch review] miss adopt orphaned resources
Message-ID: <1875A7DA-A097-4AB9-AF6B-A55EADFB479E@chinac.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

commit afcabe14eab9eb9722ab0715aec15f0375416a35
Author: Huan Zhang <zhanghuan@chinac.com>
Date:   Wed Jun 14 19:51:07 2017 +0800

    miss adopt orphaned resources

    1. dm_uuid is 68 byte length, but buf is 64 which
       will cause miss match uuid from lv lock manager
    2. no lv lock_type path in dm config, use lock_args instead

    Signed-off-by: Zhang Huan <zhanghuan@chinac.com>

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 4d96e67..b6f3df9 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4907,14 +4907,10 @@ static int get_lockd_vgs(struct list_head *vg_lockd)
                                continue;

                        for (lv_cn = md_cn->child; lv_cn; lv_cn = lv_cn->sib) {
-                               snprintf(find_str_path, PATH_MAX, "%s/lock_type", lv_cn->key);
-                               lock_type = dm_config_find_str(lv_cn, find_str_path, NULL);
-
-                               if (!lock_type)
-                                       continue;
-
                                snprintf(find_str_path, PATH_MAX, "%s/lock_args", lv_cn->key);
                                lock_args = dm_config_find_str(lv_cn, find_str_path, NULL);
+                               if (!lock_args)
+                                       continue;

                                snprintf(find_str_path, PATH_MAX, "%s/id", lv_cn->key);
                                lv_uuid = dm_config_find_str(lv_cn, find_str_path, NULL);
@@ -4960,7 +4956,7 @@ out:
        return rv;
 }

-static char _dm_uuid[64];
+static char _dm_uuid[72];

 static char *get_dm_uuid(char *dm_name)
 {
> ??
> ???????
> ??: 17798706680






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20170614/8ca288c6/attachment.htm>
