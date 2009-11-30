From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:15 +0100
Subject: [PATCH 15/23] Replicator: using vgs_missed for error count
In-Reply-To: <1259581043-15308-15-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-12-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-13-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-14-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-15-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-16-git-send-email-zkabelac@redhat.com>
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


