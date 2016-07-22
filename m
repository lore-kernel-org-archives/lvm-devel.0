From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 22 Jul 2016 19:51:43 +0000 (UTC)
Subject: master - lvmlockd: improve activation locking error message
Message-ID: <20160722195143.F23B860E9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6acf922e625912e88e064fb03a5188bdcc8bb43
Commit:        f6acf922e625912e88e064fb03a5188bdcc8bb43
Parent:        2c3b92b550ee1ba0c165acb7da87cc5cd8cf3eb9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 22 14:50:33 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 22 14:50:33 2016 -0500

lvmlockd: improve activation locking error message

to include the LV type
---
 lib/locking/lvmlockd.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e025428..03d0014 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1971,8 +1971,9 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		mode = def_mode;
 
 	if (mode && !strcmp(mode, "sh") && (flags & LDLV_MODE_NO_SH)) {
-		log_error("Shared activation not compatible with LV type: %s/%s",
-			  vg->name, lv_name);
+		struct logical_volume *lv = find_lv(vg, lv_name);
+		log_error("Shared activation not compatible with LV type %s of %s/%s",
+			  lv ? lvseg_name(first_seg(lv)) : "", vg->name, lv_name);
 		return 0;
 	}
 


