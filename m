From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Nov 2014 13:50:05 +0000 (UTC)
Subject: master - lvconvert: earlier detection of conflicting names
Message-ID: <20141124135005.9A7F1613B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e80265c368f135bf7a92c5bb4ed49948a76f712
Commit:        1e80265c368f135bf7a92c5bb4ed49948a76f712
Parent:        a058fab118b74ddddc8492752748f0a68c014ce6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 24 00:35:27 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 24 14:39:04 2014 +0100

lvconvert: earlier detection of conflicting names

Detect same LV names for lvconvert prior opening VG.
i.e. lvconvert --thinpool vg/lvol0  -T lvol0
---
 test/shell/lvconvert-thin.sh |    4 ++--
 tools/lvconvert.c            |   25 +++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 74484b1..951f694 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -53,7 +53,7 @@ lvchange -an $vg/$lv1
 # conversion fails for mirror segment type
 fail lvconvert --thinpool $vg/$lv1
 # cannot use same LV
-fail lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
+invalid lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
 
 prepare_lvs
 
@@ -104,7 +104,7 @@ invalid lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 invalid lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 # cannot use same LV for pool and convertion
-fail lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
+invalid lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
 
 # Warning about smaller then suggested
 lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8436c24..c7acd5d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -76,6 +76,28 @@ struct lvconvert_params {
 	thin_discards_t discards;
 };
 
+static int _lvconvert_validate_names(struct lvconvert_params *lp)
+{
+	int i, j;
+	const char *names[] = {
+		(lp->lv_name == lp->pool_data_name) ? NULL : lp->lv_name, "converted",
+		lp->pool_data_name, "pool",
+		lp->pool_metadata_name, "pool metadata",
+		lp->origin_name, "origin",
+	};
+
+	for (i = 0; i < DM_ARRAY_SIZE(names); i += 2)
+		if (names[i])
+			for (j = i + 2; j < DM_ARRAY_SIZE(names); j += 2)
+				if (names[j] && !strcmp(names[i], names[j])) {
+					log_error("Can't use same name %s for %s and %s volume.",
+						  names[i], names[i + 1], names[j + 1]);
+					return 0;
+				}
+
+	return 1;
+}
+
 static int _lvconvert_name_params(struct lvconvert_params *lp,
 				  struct cmd_context *cmd,
 				  int *pargc, char ***pargv)
@@ -195,6 +217,9 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 		}
 	}
 
+	if (!_lvconvert_validate_names(lp))
+		return_0;
+
 	return 1;
 }
 


