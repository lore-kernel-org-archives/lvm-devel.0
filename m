From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:20 -0500
Subject: [PATCH 17/21] Make metadata_balance_{min|max} persistent on disk.
In-Reply-To: <1265754744-17319-17-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-16-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-17-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-18-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds the ability to read/write the metadata balance min/max
values to the vg metadata.

For existing metdata that does not have a value, we set to the default
values for min/max.  In the case of the metadata balance max default value,
set the max to the # of PVs.  This should preserve existing LVM behavior
and ensure backward compatibility.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/export.c      |    2 ++
 lib/format_text/import_vsn1.c |   14 ++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 5f02b5d..2e4d2c8 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -397,6 +397,8 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 		outf(f, "allocation_policy = \"%s\"",
 		     get_alloc_string(vg->alloc));
 	}
+	outf(f, "metadata_balance_min = %u", vg->metadata_balance_min);
+	outf(f, "metadata_balance_max = %u", vg->metadata_balance_max);
 
 	return 1;
 }
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 75a61e5..436cd4d 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -23,6 +23,7 @@
 #include "pv_alloc.h"
 #include "segtype.h"
 #include "text_import.h"
+#include "defaults.h"
 
 typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
 			   struct volume_group * vg, struct config_node * pvn,
@@ -729,6 +730,16 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 			return_0;
 	}
 
+	if (!_read_uint32(vgn, "metadata_balance_min",
+			 &vg->metadata_balance_min)) {
+		vg->metadata_balance_min = DEFAULT_METADATA_BALANCE_MIN;
+	}
+
+	if (!_read_uint32(vgn, "metadata_balance_max",
+			 &vg->metadata_balance_max)) {
+		vg->metadata_balance_max = DEFAULT_METADATA_BALANCE_MAX;
+	}
+
 	/*
 	 * The pv hash memoises the pv section names -> pv
 	 * structures.
@@ -746,6 +757,9 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
+	if (vg->metadata_balance_max == DEFAULT_METADATA_BALANCE_MAX)
+		vg->metadata_balance_max = dm_list_size(&vg->pvs);
+
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
-- 
1.6.0.6


