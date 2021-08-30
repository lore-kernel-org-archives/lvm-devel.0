From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Mon, 30 Aug 2021 15:13:00 +0800
Subject: [PATCH 1/3] cmdlib_lvm2_init: release cmd after registration failed
In-Reply-To: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
References: <ad63f240-4bc9-9d54-616c-5c7306b5ee98@huawei.com>
Message-ID: <e542f440-3c6d-e081-4fa7-2b71f71c448b@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The cmd memory space is allocated by zalloc, and the registration fails and is not released

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 tools/lvmcmdlib.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 152d176b2..6b326893c 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -33,8 +33,10 @@ void *cmdlib_lvm2_init(unsigned static_compile, unsigned threaded)
        if (!(cmd = init_lvm(1, 1, threaded)))
                return NULL;

-       if (!lvm_register_commands(cmd, NULL))
+       if (!lvm_register_commands(cmd, NULL)) {
+               free(cmd);
                return NULL;
+       }

        return (void *) cmd;
 }
--
2.23.0


