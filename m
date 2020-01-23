From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Jan 2020 04:32:45 -0500
Subject: master - vdo: adapt for multi line vdo_format output
Message-ID: <54904.120012304324000149@us-mta-342.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf844941d4f0939a78a9e0d0e0ef932172e55bfb
Commit:        cf844941d4f0939a78a9e0d0e0ef932172e55bfb
Parent:        d7bf7091c35d3d34aae0d118fa4b78cd30cd4778
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 22 12:57:23 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 10:32:15 2020 +0100

vdo: adapt for multi line vdo_format output

Do not close pipeline after 1st. line parsed from vdo_format.
Also reprint the output for a user so new messages from vdo_format
can be seen by users.
---
 lib/metadata/vdo_manip.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 26694cc..b690e73 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -317,15 +317,17 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 	}
 
 	if (!*logical_size)
-		while (fgets(buf, sizeof(buf), f)) {
+		while (!feof(f) && fgets(buf, sizeof(buf), f)) {
 			/* TODO: Watch out for locales */
 			if (sscanf(buf, "Logical blocks defaulted to " FMTu64 " blocks", &lb) == 1) {
 				*logical_size = lb * DM_VDO_BLOCK_SIZE;
 				log_verbose("Available VDO logical blocks " FMTu64 " (%s).",
 					    lb, display_size(data_lv->vg->cmd, *logical_size));
-				break;
-			} else
-				log_warn("WARNING: Cannot parse output '%s' from %s.", buf, argv[0]);
+			}
+			if ((dpath = strchr(buf, '\n')))
+				*dpath = 0; /* cut last '\n' away */
+			if (buf[0])
+				log_print("  %s", buf); /* Print vdo_format messages */
 		}
 
 	if (!pipe_close(&pdata)) {
@@ -333,6 +335,11 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
+	if (!*logical_size) {
+		log_error("Number of VDO logical blocks was not provided by vdo_format output.");
+		return 0;
+	}
+
 	return 1;
 }
 



