From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Oct 2020 17:36:48 +0000 (GMT)
Subject: master - improve message for invalid device arg in process_each_pv
Message-ID: <20201001173648.7F2603857C41@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0143c7aebe2389ceada6ca0a314a3ff0fd9cdfef
Commit:        0143c7aebe2389ceada6ca0a314a3ff0fd9cdfef
Parent:        74ed6e8a9969bb7d20c21f88b53e6134d81eab1d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 1 12:34:36 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 1 12:34:36 2020 -0500

improve message for invalid device arg in process_each_pv

Multiple commands process pvs by name using process_each_pv()
and will now have an improved error message for a device
that's excluded by filters.
---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index f6879745b..f2372e095 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3839,7 +3839,7 @@ static int _get_arg_devices(struct cmd_context *cmd,
 		}
 
 		if (!(dil->dev = dev_cache_get(cmd, sl->str, cmd->filter))) {
-			log_error("Failed to find device for physical volume \"%s\".", sl->str);
+			log_error("Cannot use %s: %s", sl->str, devname_error_reason(sl->str));
 			ret_max = ECMD_FAILED;
 		} else {
 			strncpy(dil->pvid, dil->dev->pvid, ID_LEN);


