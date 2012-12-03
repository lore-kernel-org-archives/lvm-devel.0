From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Dec 2012 12:06:51 +0000 (UTC)
Subject: master - thin: update thin feature detection
Message-ID: <20121203120651.229A112E9@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a530c70b21e2ba93589e862b979aa3cb068d579a
Commit:        a530c70b21e2ba93589e862b979aa3cb068d579a
Parent:        5ec20e267fdc627e3bf50679b748c937fe3d79fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 3 13:03:41 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 3 13:03:41 2012 +0100

thin: update thin feature detection

Safe 1 static var and keep whole detection within one function.
---
 lib/thin/thin.c |   85 ++++++++++++++++++++++++++----------------------------
 1 files changed, 41 insertions(+), 44 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 18b819b..d7c45ca 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -37,23 +37,8 @@
 	log_error(t " segment %s of logical volume %s.", ## p, \
 		  dm_config_parent_name(sn), seg->lv->name), 0;
 
-/* List of features with their kernel target version */
-static const struct feature {
-	uint32_t maj;
-	uint32_t min;
-	unsigned thin_feature;
-	const char *feature;
-} _features[] = {
-	{ 1, 1, THIN_FEATURE_DISCARDS, "discards" },
-	{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
-	{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
-	{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
-};
-
-static const char _lvmconf[] = "global/thin_disabled_features";
-/* TODO: using static field heer, maybe should be part of segment_type */
+/* TODO: using static field here, maybe should be a part of segment_type */
 static unsigned _feature_mask;
-static int _log_feature_mask;
 
 static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
@@ -557,11 +542,28 @@ static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
 				unsigned *attributes)
 {
+	/* List of features with their kernel target version */
+	static const struct feature {
+		uint32_t maj;
+		uint32_t min;
+		unsigned thin_feature;
+		const char *feature;
+	} const _features[] = {
+		{ 1, 1, THIN_FEATURE_DISCARDS, "discards" },
+		{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
+		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
+		{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
+	};
+
+	static const char _lvmconf[] = "global/thin_disabled_features";
 	static int _checked = 0;
 	static int _present = 0;
 	static unsigned _attrs = 0;
 	uint32_t maj, min, patchlevel;
 	unsigned i;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *str;
 
 	if (!_checked) {
 		_present = target_present(cmd, THIN_MODULE, 1);
@@ -582,13 +584,32 @@ static int _thin_target_present(struct cmd_context *cmd,
 	}
 
 	if (attributes) {
-		if (_log_feature_mask) {
+		if (!_feature_mask) {
+			/* Support runtime lvm.conf changes, N.B. avoid 32 feature */
+			if ((cn = find_config_tree_node(cmd, _lvmconf))) {
+				for (cv = cn->v; cv; cv = cv->next) {
+					if (cv->type != DM_CFG_STRING) {
+						log_error("Ignoring invalid string in config file %s.",
+							  _lvmconf);
+						continue;
+					}
+					str = cv->v.str;
+					if (!*str) {
+						log_error("Ignoring empty string in config file %s.",
+							  _lvmconf);
+						continue;
+					}
+					for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+						if (strcasecmp(str, _features[i].feature) == 0)
+							_feature_mask |= _features[i].thin_feature;
+				}
+			}
+			_feature_mask = ~_feature_mask;
 			for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
 				if ((_attrs & _features[i].thin_feature) &&
 				    !(_feature_mask & _features[i].thin_feature))
 					log_very_verbose("Target "THIN_MODULE " %s support disabled by %s",
 							 _features[i].feature, _lvmconf);
-			_log_feature_mask = 0; /* log just once */
 		}
 		*attributes = _attrs & _feature_mask;
 	}
@@ -664,11 +685,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	};
 
 	struct segment_type *segtype;
-	const struct dm_config_node *cn;
-	const struct dm_config_value *cv;
-	const char *str;
 	unsigned i;
-	unsigned mask = 0;
 
 	for (i = 0; i < sizeof(reg_segtypes)/sizeof(reg_segtypes[0]); ++i) {
 		segtype = dm_zalloc(sizeof(*segtype));
@@ -697,29 +714,9 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 		log_very_verbose("Initialised segtype: %s", segtype->name);
 	}
 
-	/* Support runtime lvm.conf changes */
-	if ((cn = find_config_tree_node(cmd, _lvmconf))) {
-		for (cv = cn->v; cv; cv = cv->next) {
-			if (cv->type != DM_CFG_STRING) {
-				log_error("Ignoring invalid string in config file %s.",
-					  _lvmconf);
-				continue;
-			}
-			str = cv->v.str;
-			if (!*str) {
-				log_error("Ignoring empty string in config file %s.",
-					  _lvmconf);
-				continue;
-			}
-			for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
-				if (strcasecmp(str, _features[i].feature) == 0)
-					mask |= _features[i].thin_feature;
-		}
-		_log_feature_mask = (mask != 0);
-	}
 
-	/* Store as 'and' mask in static field */
-	_feature_mask = ~mask;
+	/* Reset mask for recalc */
+	_feature_mask = 0;
 
 	return 1;
 }


