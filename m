From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Dec 2012 10:57:58 +0000 (UTC)
Subject: master - thin: reworked thin feature detection
Message-ID: <20121203105758.6606322CE@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ec20e267fdc627e3bf50679b748c937fe3d79fb
Commit:        5ec20e267fdc627e3bf50679b748c937fe3d79fb
Parent:        99018b37ee9e916662ebd482ac8fe0f36bbd7ac8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 3 11:52:04 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 3 11:57:40 2012 +0100

thin: reworked thin feature detection

Rework thin feature detection to support runtime
section to allow to disable them selectively.

New lvm.conf option is born: global/thin_disabled_features
---
 WHATS_NEW           |    1 +
 doc/example.conf.in |   10 ++++++
 lib/thin/thin.c     |   91 ++++++++++++++++++++++++++++++++++++--------------
 3 files changed, 76 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ceb2295..cff005d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lvm.conf option global/thin_disabled_features.
   Add lvconvert support to swap thin pool metadata volume.
   Implement internal function detach_pool_metadata_lv().
   Fix lvm2app to return all property sizes in bytes.
diff --git a/doc/example.conf.in b/doc/example.conf.in
index 1a3ee1b..872d6ef 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -524,6 +524,16 @@ global {
     # String with options passed with thin_check command. By default,
     # option '-q' is for quiet output.
     thin_check_options = [ "-q" ]
+
+    # If set, given features are not used by thin driver.
+    # This can be helpful not just for testing, but i.e. allows to avoid
+    # using problematic implementation of some thin feature.
+    # Features:
+    #   block_size
+    #   discards
+    #   discards_non_power_2
+    #
+    # thin_disabled_features = [ "discards", "block_size" ]
 }
 
 activation {
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index f6ac437..18b819b 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -37,6 +37,24 @@
 	log_error(t " segment %s of logical volume %s.", ## p, \
 		  dm_config_parent_name(sn), seg->lv->name), 0;
 
+/* List of features with their kernel target version */
+static const struct feature {
+	uint32_t maj;
+	uint32_t min;
+	unsigned thin_feature;
+	const char *feature;
+} _features[] = {
+	{ 1, 1, THIN_FEATURE_DISCARDS, "discards" },
+	{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
+	{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },
+	{ 1, 5, THIN_FEATURE_DISCARDS_NON_POWER_2, "discards_non_power_2" },
+};
+
+static const char _lvmconf[] = "global/thin_disabled_features";
+/* TODO: using static field heer, maybe should be part of segment_type */
+static unsigned _feature_mask;
+static int _log_feature_mask;
+
 static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
 				unsigned *attributes);
@@ -541,8 +559,9 @@ static int _thin_target_present(struct cmd_context *cmd,
 {
 	static int _checked = 0;
 	static int _present = 0;
-	static int _attrs = 0;
+	static unsigned _attrs = 0;
 	uint32_t maj, min, patchlevel;
+	unsigned i;
 
 	if (!_checked) {
 		_present = target_present(cmd, THIN_MODULE, 1);
@@ -552,35 +571,27 @@ static int _thin_target_present(struct cmd_context *cmd,
 			return 0;
 		}
 
-		if (maj >=1 && min >= 1)
-			_attrs |= THIN_FEATURE_DISCARDS;
-		else
-		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
-			log_debug("Target " THIN_MODULE " does not support discards.");
-
-		if (maj >=1 && min >= 1)
-			_attrs |= THIN_FEATURE_EXTERNAL_ORIGIN;
-		else
-		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
-			log_debug("Target " THIN_MODULE " does not support external origins.");
-
-		if (maj >=1 && min >= 4)
-			_attrs |= THIN_FEATURE_BLOCK_SIZE;
-		else
-		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
-			log_debug("Target " THIN_MODULE " does not support non power of 2 block sizes.");
-
-		if (maj >=1 && min >= 5)
-			_attrs |= THIN_FEATURE_DISCARDS_NON_POWER_2;
-		else
-		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
-			log_debug("Target " THIN_MODULE " does not support discards for non power of 2 block sizes.");
+		for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+			if (maj >= _features[i].maj && min >= _features[i].min)
+				_attrs |= _features[i].thin_feature;
+			else
+				log_very_verbose("Target " THIN_MODULE " does not support %s.",
+						 _features[i].feature);
 
 		_checked = 1;
 	}
 
-	if (attributes)
-		*attributes = _attrs;
+	if (attributes) {
+		if (_log_feature_mask) {
+			for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+				if ((_attrs & _features[i].thin_feature) &&
+				    !(_feature_mask & _features[i].thin_feature))
+					log_very_verbose("Target "THIN_MODULE " %s support disabled by %s",
+							 _features[i].feature, _lvmconf);
+			_log_feature_mask = 0; /* log just once */
+		}
+		*attributes = _attrs & _feature_mask;
+	}
 
 	return _present;
 }
@@ -653,7 +664,11 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 	};
 
 	struct segment_type *segtype;
+	const struct dm_config_node *cn;
+	const struct dm_config_value *cv;
+	const char *str;
 	unsigned i;
+	unsigned mask = 0;
 
 	for (i = 0; i < sizeof(reg_segtypes)/sizeof(reg_segtypes[0]); ++i) {
 		segtype = dm_zalloc(sizeof(*segtype));
@@ -682,5 +697,29 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 		log_very_verbose("Initialised segtype: %s", segtype->name);
 	}
 
+	/* Support runtime lvm.conf changes */
+	if ((cn = find_config_tree_node(cmd, _lvmconf))) {
+		for (cv = cn->v; cv; cv = cv->next) {
+			if (cv->type != DM_CFG_STRING) {
+				log_error("Ignoring invalid string in config file %s.",
+					  _lvmconf);
+				continue;
+			}
+			str = cv->v.str;
+			if (!*str) {
+				log_error("Ignoring empty string in config file %s.",
+					  _lvmconf);
+				continue;
+			}
+			for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+				if (strcasecmp(str, _features[i].feature) == 0)
+					mask |= _features[i].thin_feature;
+		}
+		_log_feature_mask = (mask != 0);
+	}
+
+	/* Store as 'and' mask in static field */
+	_feature_mask = ~mask;
+
 	return 1;
 }


