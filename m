From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:38 +0000 (GMT)
Subject: main - metadata: remember crc32 when writing vg metadata
Message-ID: <20210927165738.8D146385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a42ea349f6733fda6eef7741c49208274b0a5388
Commit:        a42ea349f6733fda6eef7741c49208274b0a5388
Parent:        a3352f08f687e1db4bb20a2f1b1c52bb888b9d97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 11:41:03 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:49:41 2021 +0200

metadata: remember crc32 when writing vg metadata

Preserve computed crc32 check from first written PV, just like we
preserve generated metadata.

Also there is no need to call crc32 twice on wrapping buffer with 2 calcs,
result must be always the same as with single crc32 checking.
---
 WHATS_NEW                     |  1 +
 lib/format_text/format-text.c | 13 ++++++-------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e9a5de820..6106edbfd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Optimize computation of crc32 check sum with multiple PVs.
   Enhance recover path on cache creation failure.
   Filter out unsupported MQ/SMQ cache policy setting.
   Fix memleak in mpath filter.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 44c77d027..29efa8ff6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -42,6 +42,7 @@ struct text_fid_context {
 	char *write_buf;         /* buffer containing metadata text to write to disk */
 	uint32_t write_buf_size; /* mem size of write_buf, increases in 64K multiples */
 	uint32_t new_metadata_size; /* size of text metadata in buf */
+	uint32_t checksum;       /* crc32 checksum for new metadata */
 	unsigned preserve:1;
 };
 
@@ -542,6 +543,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	uint64_t write2_start = 0, write2_last = 0, write2_size = 0;
 	uint32_t write1_over = 0, write2_over = 0;
 	uint32_t write_buf_size;
+	uint32_t checksum;
 	uint32_t extra_size;
 	uint32_t bad_fields = 0;
 	char *write_buf = NULL;
@@ -601,6 +603,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		write_buf = fidtc->write_buf;
 		write_buf_size = fidtc->write_buf_size;
 		new_size = fidtc->new_metadata_size;
+		checksum = fidtc->checksum;
 	} else {
 		if (!vg->write_count++)
 			(void) dm_snprintf(desc, sizeof(desc), "Write from %s.", vg->cmd->cmd_line);
@@ -631,6 +634,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		dm_config_destroy(cft);
 		if (!vg->vg_precommitted)
 			goto_out;
+
+		fidtc->checksum = checksum = calc_crc(INITIAL_CRC, (uint8_t *)write_buf, new_size);
 	}
 
 	log_debug_metadata("VG %s seqno %u metadata write to %s mda_start %llu mda_size %llu mda_last %llu",
@@ -954,13 +959,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	dev_unset_last_byte(mdac->area.dev);
 
-	rlocn_new->checksum = calc_crc(INITIAL_CRC,
-				       (uint8_t *)write_buf,
-				       (uint32_t)(new_size - new_wrap));
-	if (new_wrap)
-		rlocn_new->checksum = calc_crc(rlocn_new->checksum,
-					(uint8_t *)write_buf + new_size - new_wrap,
-					(uint32_t)new_wrap);
+	rlocn_new->checksum = checksum;
 
 	r = 1;
 


