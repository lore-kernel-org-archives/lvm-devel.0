From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:21 +0000 (UTC)
Subject: master - backup: show warning once per command
Message-ID: <20161218185221.3D29D60E36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75f23880934a8c1cb192e9a898261320db15043a
Commit:        75f23880934a8c1cb192e9a898261320db15043a
Parent:        5bb6266046b11e6e4b47596689e3f4a75ba692a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 18 16:36:33 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:38:30 2016 +0100

backup: show warning once per command

When command calls backup() more then once (which is actually not
wanted) this warning message is shown repeatedly:

"WARNING: This metadata update is NOT backed up."

Instead now print message just once and less confuse user.
---
 WHATS_NEW                  |    1 +
 lib/format_text/archiver.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e7abf59..fbaa369 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Warn about command not making metadata backup just once per command.
   Enable usage of cached volume as thin volume's external origin.
   Support cache volume activation with -real layer.
   Improve search of lock-holder for external origin and thin-pool.
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 92799e4..d381155 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -35,6 +35,7 @@ struct archive_params {
 struct backup_params {
 	int enabled;
 	char *dir;
+	int suppress;
 };
 
 int archive_init(struct cmd_context *cmd, const char *dir,
@@ -235,7 +236,8 @@ static int _backup(struct volume_group *vg)
 int backup_locally(struct volume_group *vg)
 {
 	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
-		log_warn("WARNING: This metadata update is NOT backed up");
+		log_warn_suppress(vg->cmd->backup_params->suppress++,
+				  "WARNING: This metadata update is NOT backed up.");
 		return 1;
 	}
 


