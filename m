From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:07:49 -0400
Subject: 2018-06-01-stable - vgchange: fix error code in error path
Message-ID: <201806221307.w5MD7n7n019624@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4479228d324fff4863a068ae02c775fd52fb58fb
Commit:        4479228d324fff4863a068ae02c775fd52fb58fb
Parent:        4afb5971b93af79f81dfb3fff33b25fec270ac37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 13 15:57:51 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 12:29:42 2018 +0200

vgchange: fix error code in error path

This rather hard to hit error path used wrong return value to signal
real error.
---
 tools/vgchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 531bedc..623517b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -199,7 +199,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	    strcmp(vg->system_id, cmd->system_id) &&
 	    do_activate) {
 		log_error("Cannot activate LVs in a foreign VG.");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/*


