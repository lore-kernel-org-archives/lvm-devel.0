From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 20:10:57 +0000 (UTC)
Subject: master - lvcreate: fix LVM_VG_NAME detection
Message-ID: <20170215201057.105B860F57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2556498ee191cc9eaa505c611c5570937ff32315
Commit:        2556498ee191cc9eaa505c611c5570937ff32315
Parent:        4a30f5f9b0a3677af6f32260ee84ec5c2a6c8393
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 14:09:45 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 14:10:46 2017 -0600

lvcreate: fix LVM_VG_NAME detection

Commit d3af0e7528dbba30824379fc98cb4db437559ad5 was
not quite right in testing if the env var was set.
---
 tools/lvmcmdline.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 41ae8c4..ed32f1c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1280,7 +1280,6 @@ check_val:
 static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp, char **argv)
 {
 	const char *name;
-	char *gotenv = NULL;
 
 	/*
 	 * rp is the index in required_pos_args[] of the required positional arg.
@@ -1315,9 +1314,9 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
 	    (arg_is_set(cmd, name_ARG) ||
 	     arg_is_set(cmd, thinpool_ARG) ||
 	     arg_is_set(cmd, cachepool_ARG) ||
-	     (gotenv = getenv("LVM_VG_NAME")))) {
+	     getenv("LVM_VG_NAME"))) {
 
-		if (gotenv)
+		if (getenv("LVM_VG_NAME"))
 			return 1;
 
 		if ((name = arg_str_value(cmd, name_ARG, NULL))) {


