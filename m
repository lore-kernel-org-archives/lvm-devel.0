From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 10 Dec 2009 13:54:00 +0100
Subject: [PATCH 4/4] Call dm_pool_destroy on allocation error path
In-Reply-To: <cover.1260449368.git.zkabelac@redhat.com>
References: <cover.1260449368.git.zkabelac@redhat.com>
Message-ID: <6204cb38b82c8c7137c69d545a1eb08238680809.1260449368.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not leave allocated mem pool in error path

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 44a8a0a..65c11c4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2380,7 +2380,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
 		log_error("vg allocation failed");
-		return NULL;
+		goto bad;
 	}
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
-- 
1.6.5.3


