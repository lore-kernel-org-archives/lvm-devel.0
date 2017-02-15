From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 18:09:37 +0000 (UTC)
Subject: master - lvcreate: LVM_VG_NAME applies even without name arg
Message-ID: <20170215180937.6BF4760FDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3af0e7528dbba30824379fc98cb4db437559ad5
Commit:        d3af0e7528dbba30824379fc98cb4db437559ad5
Parent:        7417c8acfa0e9274fbfcf3220630ac3b66e88fb4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 12:07:51 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 12:07:51 2017 -0600

lvcreate: LVM_VG_NAME applies even without name arg

There was a small flaw in the logic regarding when LVM_VG_NAME
can replace a VG position arg.
---
 tools/lvmcmdline.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 02aaff2..41ae8c4 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1280,6 +1280,7 @@ check_val:
 static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp, char **argv)
 {
 	const char *name;
+	char *gotenv = NULL;
 
 	/*
 	 * rp is the index in required_pos_args[] of the required positional arg.
@@ -1311,14 +1312,19 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 	if (!strcmp(cmd->name, "lvcreate") &&
 	    (rp == 0) &&
 	    val_bit_is_set(commands[ci].required_pos_args[rp].def.val_bits, vg_VAL) &&
-	    (arg_is_set(cmd, name_ARG) || arg_is_set(cmd, thinpool_ARG) || arg_is_set(cmd, cachepool_ARG))) {
+	    (arg_is_set(cmd, name_ARG) ||
+	     arg_is_set(cmd, thinpool_ARG) ||
+	     arg_is_set(cmd, cachepool_ARG) ||
+	     (gotenv = getenv("LVM_VG_NAME")))) {
+
+		if (gotenv)
+			return 1;
+
 		if ((name = arg_str_value(cmd, name_ARG, NULL))) {
-			if (strstr(name, "/") || getenv("LVM_VG_NAME"))
+			if (strstr(name, "/"))
 				return 1;
 		}
 
-		/* FIXME: does LVM_VG_NAME also work with --thinpool/--cachepool ? */
-
 		if ((name = arg_str_value(cmd, thinpool_ARG, NULL))) {
 			if (strstr(name, "/"))
 				return 1;


