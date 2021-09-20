From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:11 +0000 (GMT)
Subject: main - cov: add explicit NULL pointer check
Message-ID: <20210920133011.029BC3858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ebd150366f0852e7ebd32e7743e6a135138320a0
Commit:        ebd150366f0852e7ebd32e7743e6a135138320a0
Parent:        752a9ec4b44198554b9f998ed6e4a837878fc49f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:24:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: add explicit NULL pointer check

Make obvious to coverity strcmp() is not getting NULL pointer.
---
 lib/config/config.c      | 2 +-
 libdm/dm-tools/dmsetup.c | 7 ++++---
 test/unit/run.c          | 2 +-
 tools/command.c          | 4 ++--
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index aedbb2b1e..0cb0da121 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -932,7 +932,7 @@ static int _check_value_differs_from_default(struct cft_check_handle *handle,
 				} else {
 					str = v_def ? v_def->v.str
 						    : cfg_def_get_default_value(handle->cmd, def, CFG_TYPE_STRING, NULL);
-					diff = strcmp(str, v->v.str);
+					diff = str ? strcmp(str, v->v.str) : 0;
 				}
 				break;
 			case DM_CFG_EMPTY_ARRAY:
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index f431f7509..f6d1ecf90 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -6426,9 +6426,10 @@ static const struct command *_find_command(const struct command *commands,
 {
 	int i;
 
-	for (i = 0; commands[i].name; i++)
-		if (!strcmp(commands[i].name, name))
-			return commands + i;
+	if (name)
+		for (i = 0; commands[i].name; i++)
+			if (!strcmp(commands[i].name, name))
+				return commands + i;
 
 	return NULL;
 }
diff --git a/test/unit/run.c b/test/unit/run.c
index 206857159..281991c51 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -240,7 +240,7 @@ static unsigned _filter(const char *pattern, struct test_details **tests, unsign
 	}
 
 	for (i = 0; i < nr; i++)
-		if (!regexec(&rx, tests[i]->path, 0, NULL, 0))
+		if (tests[i] && !regexec(&rx, tests[i]->path, 0, NULL, 0))
 			tests[found++] = tests[i];
 
 	regfree(&rx);
diff --git a/tools/command.c b/tools/command.c
index 48f572f7e..18ffd64ed 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -4015,9 +4015,9 @@ int main(int argc, char *argv[])
 
 	factor_common_options();
 
-	if (primary)
+	if (primary && cmdname)
 		r = _print_man(cmdname, desfile, secondary);
-	else if (secondary) {
+	else if (secondary && cmdname) {
 		r = 1;
 		_print_man_secondary(cmdname);
 	} else if (check) {


