From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:25 +0000 (UTC)
Subject: master - cleanup: reindent
Message-ID: <20140924085725.8730460E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03aeb867621ee5facbc01b95629af29b28c559a5
Commit:        03aeb867621ee5facbc01b95629af29b28c559a5
Parent:        3cef6dd721ad79bf73bbf5fa0d381ad7b71e1555
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 23 16:47:27 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

cleanup: reindent

Save some code lines.
---
 lib/activate/activate.c |    6 +-----
 tools/vgchange.c        |    5 +++--
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8843ec9..c5ff84d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -583,7 +583,7 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 	int ret = 0;
 #ifdef MODPROBE_CMD
 	char module[128];
-	const char *argv[3];
+	const char *argv[] = { MODPROBE_CMD, module, NULL };
 
 	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
 		log_error("module_present module name too long: %s",
@@ -591,10 +591,6 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 		return 0;
 	}
 
-	argv[0] = MODPROBE_CMD;
-	argv[1] = module;
-	argv[2] = NULL;
-
 	ret = exec_cmd(cmd, argv, NULL, 0);
 #endif
 	return ret;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 1a597a6..ba66b0f 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -40,8 +40,9 @@ static int _monitor_lvs_in_vg(struct cmd_context *cmd,
 		if (!monitor_dev_for_events(cmd, lv, 0, reg)) {
 			r = 0;
 			continue;
-		} else
-			(*count)++;
+		}
+
+		(*count)++;
 	}
 
 	return r;


