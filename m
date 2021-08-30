From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Mon, 30 Aug 2021 15:13:41 +0800
Subject: [PATCH 2/3] read_adopt_file: release r when exiting abnormally
In-Reply-To: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
References: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
Message-ID: <e885cc9b-4685-70c3-374a-6b5140d18c9b@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When exiting abnormally, r may not be released.At the same time, avoid freeing up other space,
set the default value of r to NULL

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 daemons/lvmlockd/lvmlockd-core.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index fef9589b9..d4d7f106f 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -938,7 +938,7 @@ static int read_adopt_file(struct list_head *vg_lockd)
        char lm_type_str[16];
        char mode[8];
        struct lockspace *ls = NULL, *ls2;
-       struct resource *r;
+       struct resource *r = NULL;
        FILE *fp;

        if (MAX_ARGS != 64 || MAX_NAME != 64)
@@ -1012,6 +1012,7 @@ static int read_adopt_file(struct list_head *vg_lockd)
                }
        }

+       free_resource(r);
        fclose(fp);
        return 0;

--
2.23.0


