From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 17:19:15 +0200
Subject: [PATCH 20/23] Replicator: do not remove of replicators' LVs
In-Reply-To: <cover.1273849980.git.zkabelac@redhat.com>
References: <cover.1273849980.git.zkabelac@redhat.com>
Message-ID: <d3163376cb7b13ac2cb58b6ce96a9788e48e3b18.1273849980.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5e4a674..d50ce53 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2230,6 +2230,15 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	if (lv_is_replicator_dev(lv) ||
+	    lv_is_rimage(lv) ||
+	    lv_is_rlog(lv) ||
+	    lv_is_slog(lv)) {
+		log_error("Can't remove logical volume %s used by a "
+			  "replicator.", lv->name);
+		return 0;
+	}
+
 	if (lv->status & LOCKED) {
 		log_error("Can't remove locked LV %s", lv->name);
 		return 0;
-- 
1.7.0.1


