From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 30 Nov 2015 22:36:37 +0000 (UTC)
Subject: master - lvconvert: Improve message for raid without -m.
Message-ID: <20151130223637.91F7D60E76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46c8d6bb8ae91ee67c8633496cc6c3d92bb4f3ce
Commit:        46c8d6bb8ae91ee67c8633496cc6c3d92bb4f3ce
Parent:        eb22f7c8f7351a38fc4447f56ff588f497037c23
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 30 22:36:05 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 30 22:36:05 2015 +0000

lvconvert: Improve message for raid without -m.

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0096d1e..d2bdb58 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Avoid misleading error with -m is omitted with lvconvert to raid types.
 
 Version 2.02.136 - 28th November 2015
 =====================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 72be45b..b309b9e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -242,9 +242,9 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	if (!type_str || !*type_str)
 		return 1;
 
-	if (!strcmp(type_str, "mirror")) {
+	if (!strcmp(type_str, "mirror") || !strncmp(type_str, "raid", 4)) {
 		if (!arg_count(cmd, mirrors_ARG)) {
-			log_error("--type mirror requires -m/--mirrors");
+			log_error("Mirror and raid conversions require -m/--mirrors");
 			return 0;
 		}
 		return 1;


