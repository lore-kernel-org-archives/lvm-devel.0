From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:55 +0100
Subject: [PATCH 9/9] Wait for devices being created
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <2358e548df699d4703bbd5d127755306a6d21e17.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Before command's exit and before device is needed for open in set_lv().

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    3 +++
 tools/lvmcmdline.c      |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6f553cd..48e4b7c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2999,6 +2999,9 @@ int set_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	struct device *dev;
 	char *name;
 
+	if (!unlock_fs(cmd)) /* waits until device is ready for regular open */
+		stack;
+
 	/*
 	 * FIXME:
 	 * <clausen> also, more than 4k
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9f20d4b..2fba753 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1117,6 +1117,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	ret = cmd->command->fn(cmd, argc, argv);
 
+	if (!unlock_fs(cmd))
+		stack;
+
 	fin_locking();
 
       out:
-- 
1.7.3.3


