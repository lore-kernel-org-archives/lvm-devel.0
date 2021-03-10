From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:44 +0000 (GMT)
Subject: main - cov: variable initialization
Message-ID: <20210310003644.897DD3858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a0367524182f55e7e982f0b5700d90f2a9519e2
Commit:        8a0367524182f55e7e982f0b5700d90f2a9519e2
Parent:        bee9b5c1d8d8f54c3ffe3c96abd2ce28cd2b5558
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 16:05:46 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:34:58 2021 +0100

cov: variable initialization

---
 lib/device/device_id.c       | 2 +-
 lib/format_text/text_label.c | 2 +-
 tools/pvscan.c               | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 1c4ba78f6..2de8b0a14 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -761,7 +761,7 @@ out:
 
 static void _device_ids_update_try(struct cmd_context *cmd)
 {
-	int held;
+	int held = 0;
 
 	/* Defer updates to non-pvscan-cache commands. */
 	if (cmd->pvscan_cache_single) {
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 1674126c8..be5195039 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -379,7 +379,7 @@ static int _text_read(struct cmd_context *cmd, struct labeller *labeller, struct
 	struct label_header *lh = (struct label_header *) label_buf;
 	struct pv_header *pvhdr;
 	struct pv_header_extension *pvhdr_ext;
-	struct metadata_area *mda;
+	struct metadata_area *mda = NULL;
 	struct metadata_area *mda1 = NULL;
 	struct metadata_area *mda2 = NULL;
 	struct disk_locn *dlocn_xl;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index fdd8c482f..8bcfe311c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1088,7 +1088,7 @@ static int _get_args(struct cmd_context *cmd, int argc, char **argv,
 	struct arg_value_group_list *current_group;
 	struct pvscan_arg *arg;
 	const char *arg_name;
-	int major, minor;
+	int major = -1, minor = -1;
 
 	/* Process position args, which can be /dev/name or major:minor */
 


