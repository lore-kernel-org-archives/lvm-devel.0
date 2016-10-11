From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 11 Oct 2016 22:30:23 +0000 (UTC)
Subject: master - lvconvert: fix RAID SubLV --splitmirror regression
Message-ID: <20161011223023.1F89660205@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8859d4508a9862af25b4c7d75aee84367b19da79
Commit:        8859d4508a9862af25b4c7d75aee84367b19da79
Parent:        e57fd9d96327f1f715748de99c23f9521a2d7b9b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 12 00:24:57 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 12 00:24:57 2016 +0200

lvconvert: fix RAID SubLV --splitmirror regression

Commit 088b3d036a73a7d947f6e9b12e8fad8a9f40d97f allowed repair on cache origin RAID LVs
and restricted lvconvert actions on RAID SubLVs to change number of mirrors, repair,
replace and type changes in order to avoid unsuitable coversions on them.

This introduced a regression prohibiting --splitmirrors on any RAID SubLVs
(e.g. of cache or thin LVs; lvconvert-{cache,thin}-raid.sh tests failing).

Fix allows split mirrors again.

Fix some indenting whilst on it.
---
 tools/lvconvert.c |   49 +++++++++++++++++++++++++------------------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 48e8cc8..c3ec1a6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4272,28 +4272,29 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	/* Permitted convert options on visible or hidden RaidLVs */
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 	const char *permitted_options = lv_is_visible(lv) ?
-	  	"  --mirrors\n"
-	  	"  --splitmirrors\n"
-	  	"  --merge\n"
-	  	"  --repair\n"
-	  	"  --replace\n"
-	  	"  --type snapshot\n"
-	  	"  --type thin\n"
-	  	"  --type cache\n"
-	  	"  --type thin-pool\n"
-	  	"  --type cache-pool\n"
-	  	"  --type raid*\n"
-	  	"  --type mirror\n"
-	  	"  --type striped\n"
-	  	"  --type linear\n"
+		"  --mirrors\n"
+		"  --splitmirrors\n"
+		"  --merge\n"
+		"  --repair\n"
+		"  --replace\n"
+		"  --type snapshot\n"
+		"  --type thin\n"
+		"  --type cache\n"
+		"  --type thin-pool\n"
+		"  --type cache-pool\n"
+		"  --type raid*\n"
+		"  --type mirror\n"
+		"  --type striped\n"
+		"  --type linear\n"
 		:
-	  	"  --mirrors\n"
-	  	"  --repair\n"
-	  	"  --replace\n"
-	  	"  --type raid*\n"
-	  	"  --type mirror\n"
-	  	"  --type striped\n"
-	  	"  --type linear\n";
+		"  --mirrors\n"
+		"  --splitmirrors\n"
+		"  --repair\n"
+		"  --replace\n"
+		"  --type raid*\n"
+		"  --type mirror\n"
+		"  --type striped\n"
+		"  --type linear\n";
 
 	/* Applicable to any hidden _or_ visible LVs. */
 	if (arg_is_set(cmd, mirrors_ARG))
@@ -4305,6 +4306,9 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_is_set(cmd, replace_ARG))
 		return _convert_raid_replace(cmd, lv, lp);
 
+	if (arg_is_set(cmd, splitmirrors_ARG))
+		return _convert_raid_splitmirrors(cmd, lv, lp);
+
 	if (segtype_is_raid(lp->segtype)) {
 		/* Only --type allowed on hidden RaidLV. */
 		if (!lv_is_visible(lv) && !arg_is_set(cmd, type_ARG))
@@ -4324,9 +4328,6 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 
 	/* Applicable to visible LVs only. */
 	if (lv_is_visible(lv)) {
-		if (arg_is_set(cmd, splitmirrors_ARG))
-			return _convert_raid_splitmirrors(cmd, lv, lp);
-
 		if (lp->merge)
 			return _convert_raid_merge(cmd, lv, lp);
 


