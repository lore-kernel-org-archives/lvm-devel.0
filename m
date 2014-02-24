From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:08 +0000 (UTC)
Subject: master - raid: use feature attributes for raid10
Message-ID: <20140224201708.4C134612CA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95fe823eba5432bc395847076fbf187889c55cb1
Commit:        95fe823eba5432bc395847076fbf187889c55cb1
Parent:        23c069d16f40adb9c59caa686904bb3f23ab6fca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 13:15:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:10:13 2014 +0100

raid: use feature attributes for raid10

Test raid10 availability as a target feature (instead of doing
it in all the places where raid10 should be checked).

TODO: activation needs runtime validation - so metadata with raid10
are skipped from activation in user-friendly way in lvm2.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.h |    5 +++++
 lib/raid/raid.c         |   36 +++++++++++++++++++++++++++++++++---
 tools/lvcreate.c        |   19 ++++++++-----------
 4 files changed, 47 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 05f5042..29d1554 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Enhance raid code with feature flags, for now checks for raid10.
   Move parsing of VG metadata from vg_commit() back to vg_write() (2.02.99)
   Avoid a PV label scan while in a critical section.
   Remove (always 0) skip argument from lv_activation_skip().
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 3da83ea..c3cf3d9 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -67,6 +67,11 @@ enum {
 	THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND	= (1 << 6),
 };
 
+/* raid target attribute flags */
+enum {
+	RAID_FEATURE_RAID10			= (1 << 0), /* version 1.3 */
+};
+
 void set_activation(int activation);
 int activation(void);
 
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 9f7bbd1..e592573 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -326,15 +326,45 @@ static int _raid_target_percent(void **target_state,
 
 static int _raid_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg __attribute__((unused)),
-				unsigned *attributes __attribute__((unused)))
+				unsigned *attributes)
 {
+	/* List of features with their kernel target version */
+	static const struct feature {
+		uint32_t maj;
+		uint32_t min;
+		unsigned raid_feature;
+		const char *feature;
+	} const _features[] = {
+		{ 1, 3, RAID_FEATURE_RAID10, "raid10" },
+	};
+
 	static int _raid_checked = 0;
 	static int _raid_present = 0;
+	static int _raid_attrs = 0;
+	uint32_t maj, min, patchlevel;
+	unsigned i;
 
-	if (!_raid_checked)
+	if (!_raid_checked) {
 		_raid_present = target_present(cmd, "raid", 1);
 
-	_raid_checked = 1;
+		if (!target_version("raid", &maj, &min, &patchlevel)) {
+			log_error("Cannot read target version of RAID kernel module.");
+			return 0;
+		}
+
+		for (i = 0; i < sizeof(_features)/sizeof(*_features); i++)
+			if ((maj > _features[i].maj) ||
+			    (maj == _features[i].maj && min >= _features[i].min))
+				_raid_attrs |= _features[i].raid_feature;
+			else
+				log_very_verbose("Target raid does not support %s.",
+						 _features[i].feature);
+
+		_raid_checked = 1;
+	}
+
+	if (attributes)
+		*attributes = _raid_attrs;
 
 	return _raid_present;
 }
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index c56cc7c..6da0d61 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -977,19 +977,16 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
-	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
-		log_error("%s: Required device-mapper target(s) not "
-			  "detected in your kernel", lp->segtype->name);
-		return 0;
-	} else if (!strcmp(lp->segtype->name, "raid10")) {
-		uint32_t maj, min, patchlevel;
-		if (!target_version("raid", &maj, &min, &patchlevel)) {
-			log_error("Failed to determine version of RAID kernel module");
+	if (activation() && lp->segtype->ops->target_present) {
+		if (!lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
+			log_error("%s: Required device-mapper target(s) not detected in your kernel.",
+				  lp->segtype->name);
 			return 0;
 		}
-		if ((maj != 1) || (min < 3)) {
-			log_error("RAID module does not support RAID10");
+
+		if ((strcmp(lp->segtype->name, "raid10") == 0) &&
+		    !(lp->target_attr & RAID_FEATURE_RAID10)) {
+			log_error("RAID module does not support RAID10.");
 			return 0;
 		}
 	}


