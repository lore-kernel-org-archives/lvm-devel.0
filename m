From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:16 +0100
Subject: [PATCH 02/11] Add pe_start_locked flag in struct physical_volume to retain pe_start.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-3-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Normally, pe_start value is changing throughout the calculation of the
alignment and/or adding and removing metadata areas. But sometimes we
really need to retain the old pe_start value, not trying to change it.
When this flag is set, the code will try to fit new metadata areas
within this limit and it will adjust the calculation so that the
pe_start value is not changed at all if possible (so for example, we
don't overwrite any existing data areas - a restore from backups etc.).

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format_text/format-text.c |    6 ++++--
 lib/metadata/pv.h             |    1 +
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0102a15..af95cb5 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1854,8 +1854,10 @@ static int _text_pv_setup(const struct format_type *fmt,
 		/* FIXME Default from config file? vgextend cmdline flag? */
 		pv->status |= ALLOCATABLE_PV;
 	} else {
-		if (pe_start)
+		if (pe_start) {
+			pv->pe_start_locked = 1;
 			pv->pe_start = pe_start;
+		}
 
 		if (!data_alignment)
 			data_alignment = find_config_tree_int(pv->fmt->cmd,
@@ -1894,7 +1896,7 @@ static int _text_pv_setup(const struct format_type *fmt,
 		 * - Without this you get actual != expected pe_start
 		 *   failures in the testsuite.
 		 */
-		if (!pe_start && pv->pe_start < pv->pe_align)
+		if (!pv->pe_start_locked && pv->pe_start < pv->pe_align)
 			pv->pe_start = pv->pe_align;
 
 		if (extent_count)
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index a02f6f8..7cdcaf9 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -44,6 +44,7 @@ struct physical_volume {
 	/* physical extents */
 	uint32_t pe_size;
 	uint64_t pe_start;
+	int pe_start_locked;		/* If set, try to retain the PE start value. */
 	uint32_t pe_count;
 	uint32_t pe_alloc_count;
 	unsigned long pe_align;
-- 
1.7.3.2


