From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Fri, 2 Jul 2010 14:56:51 -0400
Subject: [PATCH] Fix prototype of mda_metadata_locn_offset()
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864D4@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix prototype of mda_metadata_locn_offset() to remove a lot of
warning messages as below duirng build.

metadata/metadata.h:147: warning:
type qualifiers ignored on function return type


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 lib/format_text/format-text.c |    2 +-
 lib/metadata/metadata.h       |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: LVM2-2.02.69-20100702/lib/format_text/format-text.c
===================================================================
--- LVM2-2.02.69-20100702.orig/lib/format_text/format-text.c
+++ LVM2-2.02.69-20100702/lib/format_text/format-text.c
@@ -1649,7 +1649,7 @@ static const char *_metadata_locn_name_r
 	return dev_name(mdac->area.dev);
 }
 
-static uint64_t const _metadata_locn_offset_raw(void *metadata_locn)
+static uint64_t _metadata_locn_offset_raw(void *metadata_locn)
 {
 	struct mda_context *mdac = (struct mda_context *) metadata_locn;
 
Index: LVM2-2.02.69-20100702/lib/metadata/metadata.h
===================================================================
--- LVM2-2.02.69-20100702.orig/lib/metadata/metadata.h
+++ LVM2-2.02.69-20100702/lib/metadata/metadata.h
@@ -144,7 +144,7 @@ struct metadata_area_ops {
 	 * Per location description for logging.
 	 */
 	const char *(*mda_metadata_locn_name) (void *metadata_locn);
-	uint64_t const (*mda_metadata_locn_offset) (void *metadata_locn);
+	uint64_t (*mda_metadata_locn_offset) (void *metadata_locn);
 
 	/*
 	 * Returns number of free sectors in given metadata area.

-- 
Takahiro Yasui
Hitachi Data Systems


