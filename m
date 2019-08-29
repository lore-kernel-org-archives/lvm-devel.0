From: David Teigland <teigland@sourceware.org>
Date: Thu, 29 Aug 2019 12:43:38 -0400
Subject: master - fix segfault for invalid characters in vg name
Message-ID: <201908291643.x7TGhcHX017956@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7cfbf3a394c2663fbeed17705320b83e69781720
Commit:        7cfbf3a394c2663fbeed17705320b83e69781720
Parent:        5b3fbccab9e243901f512f9db3059a3c5eb09fe8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 29 11:35:46 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 29 11:35:46 2019 -0500

fix segfault for invalid characters in vg name

Fixes a regression from commit ba7ff96faff0
"improve reading and repairing vg metadata"

where the error path for a vg name with invalid
charaters was missing an error flag, which led
to the caller not recognizing an error occured.
Previously, an error flag was hidden in the old
_vg_make_handle function.
---
 lib/metadata/metadata.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2c61bde..6d21ff9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4900,7 +4900,8 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 
 	if (!validate_name(vg_name)) {
 		log_error("Volume group name \"%s\" has invalid characters.", vg_name);
-		return NULL;
+		failure |= FAILED_NOTFOUND;
+		goto_bad;
 	}
 
 	/*


