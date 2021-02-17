From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:41 +0000 (GMT)
Subject: main - lvconvert: VDO kernel support before converting
Message-ID: <20210217105441.4FC4F382E818@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7cb25c877ad70c48fa66258f8e3f2157e2e2be5
Commit:        a7cb25c877ad70c48fa66258f8e3f2157e2e2be5
Parent:        a915cd5a46dca80bb1ce981a2ee923b8e813d887
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:13:19 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

lvconvert: VDO kernel support before converting

Early check for kernel support of VDO target before starting any
conversion work.
---
 tools/lvconvert.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ef31799fa..8bd73bb53 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5472,6 +5472,14 @@ static int _lvconvert_to_vdopool_single(struct cmd_context *cmd,
 	if (!(lvc.segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_VDO)))
 		return_0;
 
+	if (activation() && lvc.segtype->ops->target_present) {
+		if (!lvc.segtype->ops->target_present(cmd, NULL, &lvc.target_attr)) {
+			log_error("%s: Required device-mapper target(s) not detected in your kernel.",
+				  lvc.segtype->name);
+			return 0;
+		}
+	}
+
 	if (vg_is_shared(vg)) {
 		/* FIXME: need to swap locks betwen LVs? */
 		log_error("Unable to convert VDO pool in VG with lock_type %s", vg->lock_type);


