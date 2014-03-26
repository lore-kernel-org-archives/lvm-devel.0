From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Mar 2014 13:12:00 +0000 (UTC)
Subject: master - cleanup: simplify pv name size estimation
Message-ID: <20140326131200.8F68960FB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0499e87ace39997c64b33d27a65011b1b3c6cecc
Commit:        0499e87ace39997c64b33d27a65011b1b3c6cecc
Parent:        3fda296da6b992dbafeaeabeacd47fe41f78221e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 14:00:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 14:11:37 2014 +0100

cleanup: simplify pv name size estimation

Reuse buffer with size of 2 * PATH_MAX to handle worst case escape
and avoid extra calculation of espaced len.
---
 lib/format_text/export.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 883e076..319e5ea 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -450,8 +450,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	char buffer[4096];
-	char *buf;
+	char buffer[PATH_MAX * 2];
 	const char *name;
 
 	outf(f, "physical_volumes {");
@@ -472,14 +471,13 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 
 		outf(f, "id = \"%s\"", buffer);
 
-		if (!(buf = alloca(dm_escaped_len(pv_dev_name(pv))))) {
-			log_error("temporary stack allocation for device name"
-				  "string failed");
+		if (strlen(pv_dev_name(pv)) >= PATH_MAX) {
+			log_error("pv device name size is out of bounds.");
 			return 0;
 		}
 
 		outhint(f, "device = \"%s\"",
-			dm_escape_double_quotes(buf, pv_dev_name(pv)));
+			dm_escape_double_quotes(buffer, pv_dev_name(pv)));
 		outnl(f);
 
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))


