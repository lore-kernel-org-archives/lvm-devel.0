From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:25 +0000 (GMT)
Subject: main - vg_write: shift check for exported metadata
Message-ID: <20210310003625.12C8D3858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2a3bfe6ca75f151a9fa37276dc0f8e3e6dc4ba4
Commit:        d2a3bfe6ca75f151a9fa37276dc0f8e3e6dc4ba4
Parent:        17802084c90df4ced26ae395292f0fc8466e72b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 17:45:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:00:18 2021 +0100

vg_write: shift check for exported metadata

Since we now immediatelly use created buffer for CFT creation,
the result needs to be validate before such use.
---
 lib/format_text/format-text.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 3ed6aa54a..64ad4677c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -661,6 +661,11 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			(void) dm_snprintf(desc, sizeof(desc), "Write[%u] from %s.", vg->write_count, vg->cmd->cmd_line);
 
 		new_size = text_vg_export_raw(vg, desc, &write_buf, &write_buf_size);
+		if (!new_size || !write_buf) {
+			log_error("VG %s metadata writing failed", vg->name);
+			goto out;
+		}
+
 		fidtc->write_buf = write_buf;
 		fidtc->write_buf_size = write_buf_size;
 		fidtc->new_metadata_size = new_size;
@@ -681,11 +686,6 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			goto_out;
 	}
 
-	if (!new_size || !write_buf) {
-		log_error("VG %s metadata writing failed", vg->name);
-		goto out;
-	}
-
 	log_debug_metadata("VG %s seqno %u metadata write to %s mda_start %llu mda_size %llu mda_last %llu",
 			   vg->name, vg->seqno, devname,
 			   (unsigned long long)mda_start,


