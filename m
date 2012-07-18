From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jul 2012 12:39:17 +0000 (UTC)
Subject: master - thin: detect supported features from thinp target
Message-ID: <20120718123917.8F819BBF@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=260e8f24768d7a6e7c6a8018b5c2b08e7a35e35c
Commit:        260e8f24768d7a6e7c6a8018b5c2b08e7a35e35c
Parent:        c4db22bd4f3d4a7328b2e03c27a5c1edb167d47f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 25 13:38:03 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 18 14:35:17 2012 +0200

thin: detect supported features from thinp target

Add shell variable to override reported min version for testing:
LVM_THIN_VERSION_MIN
---
 WHATS_NEW               |    1 +
 lib/activate/activate.h |    9 +++++++++
 lib/thin/thin.c         |   37 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f20f4fb..54ae73b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Detect features for new 1.1 thin pool target.
   Count percentage of completeness upwards when merging a snapshot volume.
   Skip activation when using vg/lvchange --sysinit -a ay and lvmetad is active.
   Fix extending RAID 4/5/6 logical volumes
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index f473a11..6497eea 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -44,6 +44,15 @@ struct lv_activate_opts {
 /* target attribute flags */
 #define MIRROR_LOG_CLUSTERED	0x00000001U
 
+/* thin target attribute flags */
+enum {
+	/* bitfields - new features from 1.1 version */
+	THIN_FEATURE_DISCARD			= (1 << 0),
+	THIN_FEATURE_EXTERNAL_ORIGIN		= (1 << 1),
+	THIN_FEATURE_HELD_ROOT			= (1 << 2),
+	THIN_FEATURE_BLOCK_SIZE			= (1 << 3),
+};
+
 void set_activation(int activation);
 int activation(void);
 
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 47fb0ec..974293c 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -487,16 +487,51 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 
 static int _thin_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
-				unsigned *attributes __attribute__((unused)))
+				unsigned *attributes)
 {
 	static int _checked = 0;
 	static int _present = 0;
+	static int _attrs = 0;
+	uint32_t maj, min, patchlevel;
 
 	if (!_checked) {
 		_present = target_present(cmd, THIN_MODULE, 1);
+
+		if (!target_version(THIN_MODULE, &maj, &min, &patchlevel)) {
+			log_error("Cannot read " THIN_MODULE " target version.");
+			return 0;
+		}
+		log_debug("Target " THIN_MODULE " has version %d:%d:%d.",
+			  maj, min, patchlevel);
+
+		/* For testing allow to override via shell variable */
+		if (getenv("LVM_THIN_VERSION_MIN"))
+			min = atoi(getenv("LVM_THIN_VERSION_MIN"));
+
+		if (maj >=1 && min >= 1)
+			_attrs |= THIN_FEATURE_DISCARD;
+		else
+			log_verbose("Target " THIN_MODULE
+				    " without discard support.");
+
+		if (maj >=1 && min >= 1)
+			_attrs |= THIN_FEATURE_EXTERNAL_ORIGIN;
+		else
+			log_verbose("Target " THIN_MODULE
+				    " without external origin support.");
+#if 0
+		if (maj >=1 && min >= 1)
+			_attrs |= THIN_FEATURE_BLOCK_SIZE;
+		else
+			log_verbose("Target " THIN_MODULE
+				    " without non power of 2 block size.");
+#endif
 		_checked = 1;
 	}
 
+	if (attributes)
+		*attributes = _attrs;
+
 	return _present;
 }
 #endif


