From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 Jun 2021 15:25:10 +0000 (GMT)
Subject: main - pvck: add lock_global() before clean_hint_file()
Message-ID: <20210611152510.6991338515E7@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8331321070899507b904d8a0ec78b413c826ae32
Commit:        8331321070899507b904d8a0ec78b413c826ae32
Parent:        17b27464868ac7049624d9b90f68c59200866997
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Fri Jun 11 10:18:56 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 11 10:21:07 2021 -0500

pvck: add lock_global() before clean_hint_file()

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


