From: Milan Broz <mbroz@redhat.com>
Date: Thu, 12 Aug 2010 16:07:57 +0200
Subject: [PATCH 2/4] Remove assumption that --ye must be used only in --force mode
In-Reply-To: <cover.1281621747.git.mbroz@redhat.com>
References: <cover.1281621747.git.mbroz@redhat.com>
Message-ID: <f69e3d548ff87a130653f9d760e7d9e29c66bc4e.1281621747.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is not only undocumented but is is also in violation with --help
documentation.

Using --yes without --force is useful in pvcreate when it detects
old signature.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/pvremove.c |    5 -----
 tools/toollib.c  |    5 -----
 2 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/tools/pvremove.c b/tools/pvremove.c
index 8242993..c57df64 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -143,11 +143,6 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
-		return EINVALID_CMD_LINE;
-	}
-
 	for (i = 0; i < argc; i++) {
 		r = pvremove_single(cmd, argv[i], NULL);
 		if (r > ret)
diff --git a/tools/toollib.c b/tools/toollib.c
index bdb52d5..5da30f4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1344,11 +1344,6 @@ int pvcreate_params_validate(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
-		log_error("Option y can only be given with option f");
-		return 0;
-	}
-
 	pp->yes = arg_count(cmd, yes_ARG);
 	pp->force = arg_count(cmd, force_ARG);
 
-- 
1.7.1


