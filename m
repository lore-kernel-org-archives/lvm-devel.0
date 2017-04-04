From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 4 Apr 2017 18:28:26 -0400
Subject: dev-lvmguy-lvchange1 - lvchange: tidy switches
Message-ID: <201704042228.v34MSQE8020936@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b26c361e32bd45a1f87e676a45319bc143245b9
Commit:        9b26c361e32bd45a1f87e676a45319bc143245b9
Parent:        a12b3af033d8086e0399e5433a3307ebb05b9d0b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 5 00:28:08 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 5 00:28:08 2017 +0200

lvchange: tidy switches

---
 tools/lvchange.c |   87 ++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 58 insertions(+), 29 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index c68ea98..18ad47b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -956,6 +956,62 @@ static int _commit_reload(struct logical_volume *lv, uint32_t mr)
 	return 1;
 }
 
+static int _is_option_listed(int opt_enum, int *opts)
+{
+	int i;
+
+	for (i = 0; opts[i] != -1; i++)
+		if (opt_enum == opts[i])
+			return 1;
+
+	return 0;
+}
+
+/*
+ * Check @opt_enum is an option _not_ requiring per option commit/reload.
+ */
+static int _option_allows_group_commit(int opt_enum)
+{
+	int opts[] = {
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
+	return _is_option_listed(opt_enum, opts);
+}
+
+/*
+ * Check @opt_enum is an option requiring per option commit/reload.
+ */
+static int _option_requires_direct_commit(int opt_enum)
+{
+	int opts[] = {
+		discards_ARG,
+		zero_ARG,
+		cachemode_ARG,
+		cachepolicy_ARG,
+		cachesettings_ARG,
+		-1
+	};
+
+	return _is_option_listed(opt_enum, opts);
+}
+
 /*
  * For each lvchange command definintion:
  *
@@ -1004,20 +1060,13 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 		if (!arg_is_set(cmd, opt_enum))
 			continue;
 
-		switch (opt_enum) {
 		/*
 		 * Skip options requiring per option commit/reload
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
@@ -1123,28 +1172,8 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
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
+		if (_option_allows_group_commit(opt_enum))
 			continue;
-		default:
-			break;
-		}
 
 		/* Archive will only happen once per run */
 		if (!archive(lv->vg))


