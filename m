From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  4 Dec 2009 15:04:55 +0100
Subject: [PATCH 13/22] Replicator: using vgs_missed for error count
In-Reply-To: <cover.1259934415.git.zkabelac@redhat.com>
References: <cover.1259934415.git.zkabelac@redhat.com>
Message-ID: <7b59ffbdf49355d59c4cc9b77b9a7d8f8819638f.1259934415.git.zkabelac@redhat.com>
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
index f791e53..9da877e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -102,6 +102,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		count++;
 	}
 
+	expected_count -= cmd->vgs_missed;
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
 			    activate ? "Activated" : "Deactivated",
-- 
1.6.5.3


