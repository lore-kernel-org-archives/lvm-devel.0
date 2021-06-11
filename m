From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Fri, 11 Jun 2021 10:58:17 +0800
Subject: [PATCH]pvck: add lock_global() before clean_hint_file() to avoid deadlock
Message-ID: <d5cc604d-574d-8bd3-eb59-02c15af2c3cb@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I found a same problem, pvck command don't add lock_global() before clean_hint_file(), it may cause deadlock.

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 tools/pvck.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/pvck.c b/tools/pvck.c
index 74663ec43..aba6a9cc8 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3037,6 +3037,9 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG)) {
 		pv_name = argv[0];

+		if (!lock_global(cmd, "ex"))
+			return ECMD_FAILED;
+
 		clear_hint_file(cmd);

 		if (!setup_device(cmd, pv_name)) {
-- 

Regards

Wu Guanghao


