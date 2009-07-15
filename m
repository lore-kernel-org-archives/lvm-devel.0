From: Milan Broz <mbroz@redhat.com>
Date: Wed, 15 Jul 2009 15:22:02 +0200
Subject: [PATCH] Fix leaked config override mempool.
Message-ID: <4A5DD7FA.4040301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix leaked config override mempool.

pvs --config 'global { units = "<" }'
  Invalid units specification
  Updated config file invalid. Aborting.

causes in old code
    Segmentation fault
and now memory leak :-)

Fix it by properly releasing overrided config in lvm_run_command
if refresh_toolcontext() fails.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/lvmcmdline.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 10cbb12..f756a0f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -993,7 +993,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
 			log_error("Updated config file invalid. Aborting.");
-			return ECMD_FAILED;
+			ret =  ECMD_FAILED;
+			goto out;
 		}
 	}
 



