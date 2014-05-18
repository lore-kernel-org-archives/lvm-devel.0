From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 May 2014 18:10:56 +0000 (UTC)
Subject: master - cleanup: device extent_size first
Message-ID: <20140518181056.A25716026C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91284bd9b913f74a0071082d542c3c09d11524f2
Commit:        91284bd9b913f74a0071082d542c3c09d11524f2
Parent:        58777756e8453188d9d0aeb906bb74666e5bbecc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 18 20:08:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 18 20:08:07 2014 +0200

cleanup: device extent_size first

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6a24873..0eaa719 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3560,7 +3560,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 
 	if (fcmd == FSADM_CMD_RESIZE) {
 		if (dm_snprintf(size_buf, SIZE_BUF, "%" PRIu64 "K",
-				(uint64_t) lp->extents * vg->extent_size / 2) < 0) {
+				(uint64_t) lp->extents * (vg->extent_size / 2)) < 0) {
 			log_error("Couldn't generate new LV size string");
 			return 0;
 		}


