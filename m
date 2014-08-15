From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:55:04 +0000 (UTC)
Subject: master - cleanup: gcc warn fix
Message-ID: <20140815135504.8C019603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c894c3c87f7de3b1491455186fa49404685b2b10
Commit:        c894c3c87f7de3b1491455186fa49404685b2b10
Parent:        8af23092310aeb02282f5082fba447586a1da0d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 15 15:51:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:53:17 2014 +0200

cleanup: gcc warn fix

Since gcc fail to see the origin has been already set under condition
above, just set origin again.
---
 tools/lvchange.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 91c8087..db03176 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1000,6 +1000,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	if (lv_is_cow(lv) && arg_count(cmd, activate_ARG)) {
+		origin = origin_from_cow(lv);
 		if (origin->origin_count < 2)
 			snaps_msg[0] = '\0';
 		else if (dm_snprintf(snaps_msg, sizeof(snaps_msg),


