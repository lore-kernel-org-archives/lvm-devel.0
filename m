From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:31 +0000 (GMT)
Subject: main - toollib: use EINIT_FAILED for missing devs
Message-ID: <20210310231931.AC1F93858001@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d86e943b80a94427bc2cd9deed151dd84c74ffbe
Commit:        d86e943b80a94427bc2cd9deed151dd84c74ffbe
Parent:        f4543aca15743eafdc03b4ad92084ef7343f904d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 14:37:19 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

toollib: use EINIT_FAILED for missing devs

There is really no practical reason to continue running
when we fail on allocation.

It seems we may need further fine frained errors, as for
some error type we simply need to exit ASAP, while
others may still produce usable results.
---
 tools/toollib.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index de51632a6..f60847b48 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3853,7 +3853,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 
 		if (!(dil->dev = dev_cache_get(cmd, sl->str, cmd->filter))) {
 			log_error("Cannot use %s: %s", sl->str, devname_error_reason(sl->str));
-			ret_max = ECMD_FAILED;
+			ret_max = EINIT_FAILED;
 		} else {
 			strncpy(dil->pvid, dil->dev->pvid, ID_LEN);
 			dm_list_add(arg_devices, &dil->list);
@@ -4458,9 +4458,12 @@ int process_each_pv(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices)) != ECMD_PROCESSED)
-		/* get_arg_devices reports the error for any PV names not found. */
-		ret_max = ECMD_FAILED;
+	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices)) != ECMD_PROCESSED) {
+		/* get_arg_devices reports EINIT_FAILED for any PV names not found. */
+		ret_max = ret;
+		if (ret_max == ECMD_FAILED)
+			goto_out;
+	}
 
 	ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
 				  &arg_devices, &arg_tags,


