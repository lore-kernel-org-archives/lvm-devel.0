From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 5 Apr 2017 11:30:49 -0400
Subject: master - lvchange: tidy switch code in _lvchange_properties_single()
Message-ID: <201704051530.v35FUnWn014301@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9bc1c1c8ccd624762b59a46689467573bc2933e
Commit:        c9bc1c1c8ccd624762b59a46689467573bc2933e
Parent:        6fdc391baec1129d0c70913f116c04f928d083fa
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 5 17:29:31 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 5 17:29:31 2017 +0200

lvchange: tidy switch code in _lvchange_properties_single()

---
 tools/lvchange.c |   91 +++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 59 insertions(+), 32 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 1778b52..a35891e 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -974,6 +974,58 @@ static int _commit_reload(struct logical_volume *lv, uint32_t mr)
 	return 1;
 }
 
+/* Helper: check @opt_num is listed in @opts array */
+static int _is_option_listed(int opt_enum, int *options)
+{
+	int i;
+
+	for (i = 0; options[i] != -1; i++)
+		if (opt_enum == options[i])
+			return 1;
+	return 0;
+}
+
+/* Check @opt_enum is an option allowing group commit/reload */
+static int _option_allows_group_commit(int opt_enum)
+{
+	int options[] = {
+		permission_ARG,
+		alloc_ARG,
+		contiguous_ARG,
+		errorwhenfull_ARG,
+		readahead_ARG,
+		persistent_ARG,
+		addtag_ARG,
+		deltag_ARG,
+		writemostly_ARG,
+		writebehind_ARG,
+		minrecoveryrate_ARG,
+		maxrecoveryrate_ARG,
+		profile_ARG,
+		metadataprofile_ARG,
+		detachprofile_ARG,
+		setactivationskip_ARG,
+		-1
+	};
+
+	return _is_option_listed(opt_enum, options);
+}
+
+/* Check @opt_enum requires direct commit/reload */
+static int _option_requires_direct_commit(int opt_enum)
+{
+	int options[] = {
+		discards_ARG,
+		zero_ARG,
+		cachemode_ARG,
+		cachepolicy_ARG,
+		cachesettings_ARG,
+		-1
+	};
+
+	return _is_option_listed(opt_enum, options);
+}
+
 /*
  * For each lvchange command definintion:
  *
@@ -1022,20 +1074,13 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 		if (!arg_is_set(cmd, opt_enum))
 			continue;
 
-		switch (opt_enum) {
 		/*
-		 * Skip options requiring per option commit/reload
+		 * Skip options requiring direct commit/reload
 		 * to process them in the second step.
 		 */
-		case discards_ARG:
-		case zero_ARG:
-		case cachemode_ARG:
-		case cachepolicy_ARG:
-		case cachesettings_ARG:
+		if (_option_requires_direct_commit(opt_enum)) {
 			second_group++;
 			continue;
-		default:
-			break;
 		}
 
 		/* Archive will only happen once per run. */
@@ -1141,28 +1186,9 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 		if (!arg_is_set(cmd, opt_enum))
 			continue;
 
-		switch (opt_enum) {
-		/* Skip any of the already processed options */
-		case permission_ARG:
-		case alloc_ARG:
-		case contiguous_ARG:
-		case errorwhenfull_ARG:
-		case readahead_ARG:
-		case persistent_ARG:
-		case addtag_ARG:
-		case deltag_ARG:
-		case writemostly_ARG:
-		case writebehind_ARG:
-		case minrecoveryrate_ARG:
-		case maxrecoveryrate_ARG:
-		case profile_ARG:
-		case metadataprofile_ARG:
-		case detachprofile_ARG:
-		case setactivationskip_ARG:
+		/* Skip any of the already processed options which allowed for group commit/reload */
+		if (_option_allows_group_commit(opt_enum))
 			continue;
-		default:
-			break;
-		}
 
 		/* Archive will only happen once per run */
 		if (!archive(lv->vg))
@@ -1170,8 +1196,8 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 
 		mr = 0;
 
+		/* Run commit and reload after processing each of the following options */
 		switch (opt_enum) {
-		/* Process the following options which need per option metadata commit and reload */
 		case discards_ARG:
 		case zero_ARG:
 			docmds++;
@@ -1186,7 +1212,8 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 			break;
 
 		default:
-			break;
+			log_error(INTERNAL_ERROR "Failed to check for option %s",
+				  arg_long_option_name(i));
 		}
 
 		/* Display any logical volume change unless already displayed in step 1. */


