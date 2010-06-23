From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 23 Jun 2010 11:39:37 -0400
Subject: [PATCH 1/1] Only write metadata_copies to vg metadata if read or non-zero.
In-Reply-To: <1277307577-20552-1-git-send-email-dwysocha@redhat.com>
References: <1277307577-20552-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1277307577-20552-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If already present on disk, or the user sets the value, enable writing
the value out to disk.  Otherwise, skip committing metadata_copies
to the vg metadata.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/export.c         |    6 +++++-
 lib/format_text/import_vsn1.c    |    2 ++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    1 +
 4 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 52ae11c..297a47d 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -397,7 +397,11 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(vg->alloc));
 	}
-	outf(f, "metadata_copies = %u", vg->mda_copies);
+	/*
+	 * Only write to the metadata if the value is valid or non-zero.
+	 */
+	if (vg->mda_copies_valid || vg->mda_copies)
+		outf(f, "metadata_copies = %u", vg->mda_copies);
 
 	return 1;
 }
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 62bcbec..be4e7d4 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -746,7 +746,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 			return_0;
 	}
 
+	vg->mda_copies_valid = 1;
 	if (!_read_uint32(vgn, "metadata_copies", &vg->mda_copies)) {
+		vg->mda_copies_valid = 0;
 		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 	}
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b444e34..3414d8c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -282,6 +282,7 @@ struct volume_group {
 	 */
 	uint32_t read_status;
 	uint32_t mda_copies; /* target number of mdas for this VG */
+	uint32_t mda_copies_valid; /* 1 if user enables feature */
 };
 
 /* There will be one area for each stripe */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e2b36ea..2b72335 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1105,6 +1105,7 @@ int vg_set_mda_copies(struct volume_group *vg, uint32_t value)
 	 * enable some mdas on PVS
 	 */
 	vg->mda_copies = value;
+	vg->mda_copies_valid = 1;
 	return 1;
 }
 
-- 
1.6.0.6


