From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:26 +0000 (GMT)
Subject: main - cmdline: lvcreate adds vdopool as vg name provider
Message-ID: <20210302215826.C7F023851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e946a5e6904455284ae4eeaa1d149a9324b0f00e
Commit:        e946a5e6904455284ae4eeaa1d149a9324b0f00e
Parent:        f87d1a2abb9102f47d240bd0e6f2c343ddb47310
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 17:41:39 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

cmdline: lvcreate adds vdopool as vg name provider

Add same logic as with thinpool or cachepool.
---
 tools/lvmcmdline.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4e87f0cbf..b6ad66d62 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1519,7 +1519,7 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 	 * the VG position is allowed to be empty if --name VG/LV is used, or if the
 	 * LVM_VG_NAME env var is set.
 	 *
-	 * --thinpool VG/LV and --cachepool VG/LV can also function like --name 
+	 * --thinpool|--cachepool|--vdopool VG/LV can also function like --name
 	 * to provide the VG name in place of the positional arg.
 	 */
 	if (!strcmp(cmd->name, "lvcreate") &&
@@ -1528,6 +1528,7 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 	    (arg_is_set(cmd, name_ARG) ||
 	     arg_is_set(cmd, thinpool_ARG) ||
 	     arg_is_set(cmd, cachepool_ARG) ||
+	     arg_is_set(cmd, vdopool_ARG) ||
 	     getenv("LVM_VG_NAME"))) {
 
 		if (getenv("LVM_VG_NAME"))
@@ -1547,6 +1548,9 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 			if (strstr(name, "/"))
 				return 1;
 		}
+
+		if ((name = arg_str_value(cmd, vdopool_ARG, NULL)) && strstr(name, "/"))
+			return 1;
 	}
 
 	return 0;


