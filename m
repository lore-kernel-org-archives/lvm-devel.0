From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:13 +0100
Subject: [PATCH 09/18] Replicator: using vgs_missed for error count
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <04242a8f69e9c428a32d2e5d26018b3daaa550ff.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Lower expected_count for the case of missed VGs so no error is printed
in case the remote VGs are not opened. Currently it's needed only for
Replicator target.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgchange.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index b4f5d00..c976746 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -145,6 +145,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		count++;
 	}
 
+	expected_count -= cmd->vgs_missed;
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
 			    (activate == CHANGE_AN || activate == CHANGE_ALN)?
-- 
1.6.6


