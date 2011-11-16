From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:51 +0100
Subject: [PATCH 04/12] Unlock memory for vg_write
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <5dc33dd0976c54d2d11d394c0367248a172547e5.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For write we do not need to hold memory locked.
We should never write metadata in locked state.
This relaxes meny conditions and avoid problems when allocating
a lot of memory for writting metadata buffers.
(In case of huge MDA size this would lead to mismatch between
locked and unlocked memory size).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4037c0e..f9742e7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2573,6 +2573,8 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
+	/* Unlock memory if possible */
+	memlock_unlock(vg->cmd);
 	vg->seqno++;
 
         dm_list_iterate_items(pv_to_create, &vg->pvs_to_create) {
-- 
1.7.7.3


