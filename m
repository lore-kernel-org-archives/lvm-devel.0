From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Feb 2020 09:44:52 -0500
Subject: master - vdo: fix vdoformat when -V is specified
Message-ID: <56652.120021009444602865@us-mta-156.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3716aa848efef716ba8596d585a312fdb61850d3
Commit:        3716aa848efef716ba8596d585a312fdb61850d3
Parent:        8f794f2095583d41393ee9c697f470015b29f064
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 10 15:41:30 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 10 15:41:30 2020 +0100

vdo: fix vdoformat when -V is specified

The previous patch improved read of pipe when lvm2 was looking
for default logical size, but we clearly must read pipe also
for -V case, when the logical size is already defined.
---
 lib/metadata/vdo_manip.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index b690e73..335e7dd 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -316,19 +316,19 @@ static int _format_vdo_pool_data_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
-	if (!*logical_size)
-		while (!feof(f) && fgets(buf, sizeof(buf), f)) {
-			/* TODO: Watch out for locales */
+	while (!feof(f) && fgets(buf, sizeof(buf), f)) {
+		/* TODO: Watch out for locales */
+		if (!*logical_size)
 			if (sscanf(buf, "Logical blocks defaulted to " FMTu64 " blocks", &lb) == 1) {
 				*logical_size = lb * DM_VDO_BLOCK_SIZE;
 				log_verbose("Available VDO logical blocks " FMTu64 " (%s).",
 					    lb, display_size(data_lv->vg->cmd, *logical_size));
 			}
-			if ((dpath = strchr(buf, '\n')))
-				*dpath = 0; /* cut last '\n' away */
-			if (buf[0])
-				log_print("  %s", buf); /* Print vdo_format messages */
-		}
+		if ((dpath = strchr(buf, '\n')))
+			*dpath = 0; /* cut last '\n' away */
+		if (buf[0])
+			log_print("  %s", buf); /* Print vdo_format messages */
+	}
 
 	if (!pipe_close(&pdata)) {
 		log_error("Command %s failed.", argv[0]);



