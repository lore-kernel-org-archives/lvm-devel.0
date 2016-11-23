From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:57 +0000 (UTC)
Subject: master - cleanup: single LVM_SYSTEM_DIR string
Message-ID: <20161123165557.07F1160F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e38678be3fd3ceb610ec649f5036e77a64ee24b4
Commit:        e38678be3fd3ceb610ec649f5036e77a64ee24b4
Parent:        cc3895623c43dbbd6976f3c988e4ad26ad9ac9c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 21 14:54:20 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: single LVM_SYSTEM_DIR string

---
 daemons/lvmpolld/lvmpolld-data-utils.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index 99883f8..8debcdd 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -19,6 +19,8 @@
 #include <fcntl.h>
 #include <signal.h>
 
+static const char LVM_SYSTEM_DIR[] = "LVM_SYSTEM_DIR=";
+
 static char *_construct_full_lvname(const char *vgname, const char *lvname)
 {
 	char *name;
@@ -52,7 +54,7 @@ static char *_construct_lvm_system_dir_env(const char *sysdir)
 
 	*env = '\0';
 
-	if (sysdir && dm_snprintf(env, l, "LVM_SYSTEM_DIR=%s", sysdir) < 0) {
+	if (sysdir && dm_snprintf(env, l, "%s%s", LVM_SYSTEM_DIR, sysdir) < 0) {
 		dm_free(env);
 		env = NULL;
 	}
@@ -259,8 +261,8 @@ static void _pdlv_locked_dump(struct buffer *buff, const struct lvmpolld_lv *pdl
 		buffer_append(buff, tmp);
 	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvm_command_interval=\"%s\"\n", pdlv->sinterval ?: "<undefined>") > 0)
 		buffer_append(buff, tmp);
-	if (dm_snprintf(tmp, sizeof(tmp), "\t\tLVM_SYSTEM_DIR=\"%s\"\n",
-			(*pdlv->lvm_system_dir_env ? (pdlv->lvm_system_dir_env + strlen("LVM_SYSTEM_DIR=")) : "<undefined>")) > 0)
+	if (dm_snprintf(tmp, sizeof(tmp), "\t\t%s\"%s\"\n", LVM_SYSTEM_DIR,
+			(*pdlv->lvm_system_dir_env ? (pdlv->lvm_system_dir_env + (sizeof(LVM_SYSTEM_DIR) - 1)) : "<undefined>")) > 0)
 		buffer_append(buff, tmp);
 	if (dm_snprintf(tmp, sizeof(tmp), "\t\tlvm_command_pid=%d\n", pdlv->cmd_pid) > 0)
 		buffer_append(buff, tmp);


