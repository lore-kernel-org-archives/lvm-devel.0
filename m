From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:02:56 -0400
Subject: master - vgchange: fix error code in error path
Message-ID: <201806142002.w5EK2usl003568@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70b159d145dfa960a53f6f61ce735b90ec25b1e0
Commit:        70b159d145dfa960a53f6f61ce735b90ec25b1e0
Parent:        3eff3aa4f8faa5a84de2ba696b15a976fad31852
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 13 15:57:51 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

vgchange: fix error code in error path

This rather hard to hit error path used wrong return value to signal
real error.
---
 tools/vgchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 891f22a..b608d87 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -187,7 +187,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	    strcmp(vg->system_id, cmd->system_id) &&
 	    do_activate) {
 		log_error("Cannot activate LVs in a foreign VG.");
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/*


