From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:05 +0200
Subject: [PATCH 01/20] metadata: Do not try to check vg_name of a NULL PV.
Message-ID: <1375125564-1188-1-git-send-email-prockai@redhat.com>
	(sfid-20130729_211924_665686_00E04731)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/metadata/metadata.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4ae7726..632e78a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1842,7 +1842,7 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 		}
 	}
 
-	if (!allow_orphan && is_orphan_vg(pv->vg_name)) {
+	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		goto bad;
 	}
-- 
1.8.2


