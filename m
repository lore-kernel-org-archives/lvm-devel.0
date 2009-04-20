From: Milan Broz <mbroz@redhat.com>
Date: Mon, 20 Apr 2009 20:30:18 +0200
Subject: [PATCH] fix output of pvs -a fof non PV device
Message-ID: <49ECBF3A.8060006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix pvs -a for segmented output

 # pvs -a -o devices
   Volume group name (null) has invalid characters
   Skipping volume group (null)

...
_pvsegs_sub_single creates fake vg, we need to check
that pv is real here.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3057c90..f9bd154 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -376,7 +376,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 	int ret;
 	struct volume_group *old_vg = vg;
 
-	if (!vg && !is_orphan(pv)) {
+	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
 		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,



