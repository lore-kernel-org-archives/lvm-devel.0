From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:18 +0100
Subject: [PATCH 14/29] Remove unneeded check for NULL pvd->system_id
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <b7c2c8c2901eb9adcbadb9de67ad01f3d1a7f8d2.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove check is for system_id defined as int8_t[].

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/import-export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index e261737..796aa29 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -185,7 +185,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	}
 
 	/* Generate system_id if PV is in VG */
-	if (!pvd->system_id || !*pvd->system_id)
+	if (!*pvd->system_id)
 		if (!_system_id(cmd, (char *)pvd->system_id, ""))
 			return_0;
 
-- 
1.7.3.2


