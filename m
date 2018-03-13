From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:05:24 -0400
Subject: master - cleanup: matching signess
Message-ID: <201803131205.w2DC5ORD002792@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9cadbe105b7a449d98598a9329a170bce2d689e
Commit:        e9cadbe105b7a449d98598a9329a170bce2d689e
Parent:        49a8c786d5fdbf79ac60f2720d4e1433146d14f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 11 21:08:07 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

cleanup: matching signess

---
 lib/cache/lvmetad.c |    2 +-
 tools/command.c     |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b266152..589b48e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1677,7 +1677,7 @@ int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct devi
 
 	if (vg && result) {
 		seqno_after = daemon_reply_int(reply, "seqno_after", -1);
-		if ((seqno_after != vg->seqno) ||
+		if ((seqno_after != (int) vg->seqno) ||
 		    (seqno_after != daemon_reply_int(reply, "seqno_before", -1)))
 			log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
 	}
diff --git a/tools/command.c b/tools/command.c
index 10efedb..fafbaa9 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2927,7 +2927,8 @@ static void _print_man_option_desc(struct command_name *cname, int opt_enum)
 	char buf[DESC_LINE];
 	int started_cname = 0;
 	int line_count = 0;
-	int di, bi = 0;
+	int bi = 0;
+	unsigned di;
 
 	if (desc[0] != '#') {
 		printf("%s", desc);
@@ -3246,7 +3247,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 static void _print_desc_man(const char *desc)
 {
 	char buf[DESC_LINE] = {0};
-	int di = 0;
+	unsigned di;
 	int bi = 0;
 
 	for (di = 0; di < strlen(desc); di++) {


