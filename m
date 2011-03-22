From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:15 +0100
Subject: [PATCH 6/8] Use id_equal instead of strncmp()
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <6a65a35b72c347dcdb34b8a99ad647f2f34d8399.1300829383.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's better for code reading and code consistency.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1d711bc..f4d4671 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3038,8 +3038,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				continue;
 			}
 
-			if (strncmp((char *)vg->id.uuid,
-			    (char *)correct_vg->id.uuid, ID_LEN)) {
+			if (!id_equal(&vg->id, &correct_vg->id)) {
 				inconsistent = 1;
 				inconsistent_vgid = 1;
 			}
@@ -3287,7 +3286,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	    vginfo->vgname && !is_orphan_vg(vginfo->vgname)) {
 		if ((vg = _vg_read(cmd, NULL, vgid, 1,
 				   &consistent, precommitted)) &&
-		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
+		    id_equal(&vg->id, (const struct id *)vgid)) {
 			if (!consistent)
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vg->name);
@@ -3318,7 +3317,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 		consistent = 0;
 		if ((vg = _vg_read(cmd, vgname, vgid, 1, &consistent,
 				   precommitted)) &&
-		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
+		    id_equal(&vg->id, (const struct id *)vgid)) {
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);
-- 
1.7.4.1


