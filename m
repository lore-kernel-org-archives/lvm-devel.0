From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 3 May 2019 07:18:17 -0400
Subject: master - clean: avoid cleaning iterator on error path
Message-ID: <201905031118.x43BIHXF028315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c70ae1803b06dea68b2e6e1ec2176b3f3fe9707
Commit:        3c70ae1803b06dea68b2e6e1ec2176b3f3fe9707
Parent:        99de816a1bb6414e4611030c8d83766b1ff3cd65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 12:01:20 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 13:17:22 2019 +0200

clean: avoid cleaning iterator on error path

Return error dirrectly instead of using 'out' code path.
---
 tools/toollib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index b352839..8e882e9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3933,14 +3933,14 @@ static int _get_all_devices(struct cmd_context *cmd,
 
 			if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
 				log_error("device_id_list alloc failed.");
-				goto out;
+				return ECMD_FAILED;
 			}
 
 			strncpy(dil->pvid, hint->pvid, ID_LEN);
 			dil->dev = dev;
 			dm_list_add(all_devices, &dil->list);
 		}
-		return 1;
+		return ECMD_PROCESSED;
 	}
 
 	log_debug("Getting list of all devices from system");


