From: Milan Broz <mbroz@redhat.com>
Date: Thu, 09 Jul 2009 22:11:22 +0200
Subject: [PATCH] unknown segment types, part 1
In-Reply-To: <87k52h8wep.fsf@twilight.int.mornfall.net.>
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>	<4A56288F.4080604@redhat.com>
	<87k52h8wep.fsf@twilight.int.mornfall.net.>
Message-ID: <4A564EEA.10607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I tried some fixes...

- flag segment with unknown flag and skip it for activation
(maybe not in correct place, but demonstrates what I mean)

- fix segment name (possible using of deallocated memory, easily
reproduced if e.g. creating new LV on metadat with unknown segments)

(please ignore some crypto stuff - I am playing with in on my git branch :)

Milan

---
 lib/activate/dev_manager.c |   10 ++++++++++
 lib/metadata/segtype.h     |    2 ++
 lib/unknown/unknown.c      |    4 ++--
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 894c20e..225b2a8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -914,6 +914,16 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 		return 0;
 	}
 
+	if (seg_unknown(seg_present)) {
+		if (lv_is_visible(seg->lv))
+			log_error("Skipping LV %s containing unknown segment type %s.",
+				  seg->lv->name, seg_present->segtype->name);
+		else
+			log_debug("Skipping LV %s containing unknown segment type %s.",
+				  seg->lv->name, seg_present->segtype->name);
+		return 0;
+	}
+
 	/* Add mirror log */
 	if (seg->log_lv &&
 	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index c743ac3..8787fed 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -34,6 +34,7 @@ struct dev_manager;
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
 #define SEG_MONITORED		0x00000080U
 #define SEG_AREAS_ENCRYPTED	0x00000100U
+#define SEG_UNKNOWN		0x80000000U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -44,6 +45,7 @@ struct dev_manager;
 #define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
 #define seg_is_encrypted(seg)	((seg)->segtype->flags & SEG_AREAS_ENCRYPTED ? 1 : 0)
 #define seg_is_keystore(seg)	(seg_is_encrypted(seg) && seg_cannot_be_zeroed(seg))
+#define seg_unknown(seg)	((seg)->segtype->flags & SEG_UNKNOWN ? 1 : 0)
 
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 6fa44b4..e2ed807 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -93,9 +93,9 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *n
 
 	segtype->cmd = cmd;
 	segtype->ops = &_unknown_ops;
-	segtype->name = name;
+	segtype->name = dm_pool_strdup(cmd->mem, name);
 	segtype->private = NULL;
-	segtype->flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
+	segtype->flags = SEG_UNKNOWN | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 



