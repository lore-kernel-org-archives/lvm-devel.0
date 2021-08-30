From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Mon, 30 Aug 2021 15:14:17 +0800
Subject: [PATCH 3/3] read_adopt_file: fix memory leak
In-Reply-To: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
References: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
Message-ID: <bc6154a0-8e1f-8a1d-0350-a045a30c4c00@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When exiting abnormally, forget to release ls

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 daemons/lvmlockd/lvmlockd-core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index d4d7f106f..71d708603 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -970,8 +970,10 @@ static int read_adopt_file(struct list_head *vg_lockd)

                        memcpy(ls->vg_uuid, vg_uuid, 64);

-                       if ((ls->lm_type = str_to_lm(lm_type_str)) < 0)
+                       if ((ls->lm_type = str_to_lm(lm_type_str)) < 0) {
+                               free(ls);
                                goto fail;
+                       }

                        list_add(&ls->list, vg_lockd);

--
2.23.0


