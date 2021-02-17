From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:47 +0000 (GMT)
Subject: main - lvmlocdk: correct creation of dm path vg sanlock LV
Message-ID: <20210217105447.01D933857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=868b733588ff5629e1318bf3efcfbceb2ac8db8c
Commit:        868b733588ff5629e1318bf3efcfbceb2ac8db8c
Parent:        fbaf5a32bb3465d121f60db5a77df2e86b0bf49b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 14 17:47:08 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:19 2021 +0100

lvmlocdk: correct creation of dm path vg sanlock LV

Vgname may contain '-' and needs escaping '--' for /dev/mapper path.
---
 lib/locking/lvmlockd.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 24b7ff6f7..3b9abd6bf 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -382,6 +382,7 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct device *dev;
 	char path[PATH_MAX];
+	char *name;
 	uint64_t old_size_bytes;
 	uint64_t new_size_bytes;
 	uint32_t extend_bytes;
@@ -423,8 +424,10 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 	new_size_bytes = lv->size * SECTOR_SIZE;
 
-	if (dm_snprintf(path, sizeof(path), "%s/mapper/%s-%s", lv->vg->cmd->dev_dir,
-			lv->vg->name, lv->name) < 0) {
+	if (!(name = dm_build_dm_name(lv->vg->cmd->mem, lv->vg->name, lv->name, NULL)))
+		return_0;
+
+	if (dm_snprintf(path, sizeof(path), "%s/%s", dm_dir(), name) < 0) {
 		log_error("Extend sanlock LV %s name too long - extended size not zeroed.",
 			  display_lvname(lv));
 		return 0;


