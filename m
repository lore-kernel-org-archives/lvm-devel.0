From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:39 +0000 (GMT)
Subject: main - metadata: remember parsing size of VG metadata
Message-ID: <20210927165739.ACEA13858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24e90f9594a79a8be851cffe1a5e47741dbff663
Commit:        24e90f9594a79a8be851cffe1a5e47741dbff663
Parent:        a42ea349f6733fda6eef7741c49208274b0a5388
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 15:55:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:49:41 2021 +0200

metadata: remember parsing size of VG metadata

When creating lvm2 metadata for VG, lvm2 allocate some buffer,
and if buffer is not big enough, the buffer is 'reallocated' bigger,
and whole metadata creation is repeated until metadata fits.
We can try to use 'previous' metadata size as hint to reduce looping
here.
---
 lib/format_text/export.c | 2 +-
 lib/format_text/import.c | 1 +
 lib/metadata/vg.h        | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 6ece94042..fbb8fb1ee 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1071,7 +1071,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf,
 		.header = 0,
 		.out_with_comment = &_out_with_comment_raw,
 		.nl = &_nl_raw,
-		.data.buf.size = 65536,	/* Initial metadata limit */
+		.data.buf.size = vg->buffer_size_hint + 16384,	/* Initial metadata limit */
 	};
 
 	_init();
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 2687d172e..e4e526354 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -187,6 +187,7 @@ struct volume_group *text_read_metadata(struct format_instance *fid,
 
 		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
 		vg->committed_cft = cft; /* Reuse CFT for recreation of committed VG */
+		vg->buffer_size_hint = size + size2;
 		cft = NULL;
 		break;
 	}
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 8ce57acdc..96ab6a0b2 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -45,6 +45,7 @@ struct volume_group {
 	unsigned needs_backup : 1;
 	unsigned needs_write_and_commit : 1;
 	uint32_t write_count; /* count the number of vg_write calls */
+	uint32_t buffer_size_hint; /* hint with buffer size of parsed VG */
 
 	/*
 	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed


