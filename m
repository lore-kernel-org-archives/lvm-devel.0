From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:55 +0100
Subject: [PATCH 23/23] Remove dead assignment in vg_split_mdas
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <9c9444b0a208344231b42cb5197d45a377452304.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'common_mda' is assigned again with next code line.

Why is the result not important from the first call?
CHECKME!

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 27abaea..ebd19fa 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1263,15 +1263,14 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
 {
 	struct dm_list *mdas_from_in_use, *mdas_to_in_use;
 	struct dm_list *mdas_from_ignored, *mdas_to_ignored;
-	int common_mda = 0;
+	int common_mda;
 
 	mdas_from_in_use = &vg_from->fid->metadata_areas_in_use;
 	mdas_from_ignored = &vg_from->fid->metadata_areas_ignored;
 	mdas_to_in_use = &vg_to->fid->metadata_areas_in_use;
 	mdas_to_ignored = &vg_to->fid->metadata_areas_ignored;
 
-	common_mda = _move_mdas(vg_from, vg_to,
-				mdas_from_in_use, mdas_to_in_use);
+	_move_mdas(vg_from, vg_to, mdas_from_in_use, mdas_to_in_use);
 	common_mda = _move_mdas(vg_from, vg_to,
 				mdas_from_ignored, mdas_to_ignored);
 
-- 
1.7.3.4


