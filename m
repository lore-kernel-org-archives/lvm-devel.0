From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Thu, 9 Jun 2022 09:47:44 +0800
Subject: [PATCH] pvdisplay: support -a option
Message-ID: <de2155b1-0831-3374-b54b-e7ad6ac57830@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

pvdisplay already supports the -a option, but it is filtered at the begining,
so delete the redundant judgment.

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 tools/pvdisplay.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 11f38ebd2..1ed9c0d3f 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -72,7 +72,6 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
        }

        if (arg_is_set(cmd, aligned_ARG) ||
-           arg_is_set(cmd, all_ARG) ||
            arg_is_set(cmd, binary_ARG) ||
            arg_is_set(cmd, noheadings_ARG) ||
            arg_is_set(cmd, options_ARG) ||
--
2.27.0

