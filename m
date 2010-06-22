From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:36 -0400
Subject: [PATCH 03/35] Add location independent flag and functions to ignore mdas.
In-Reply-To: <1277175968-9661-3-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

First we add a 'flags' field to the location independent
metadata_area structure, and a MDA_IGNORE flag.  The
mda_is_ignored and mda_set_ignored functions are added to
manage the flag.  Adding the flag and functions gives a
library interface to ignore metadata areas independent of
the underlying location (disk, file, etc).  The location
specific read/write functions must then handle the specifics
of what this flag means to the location.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/text_label.c |    1 +
 lib/metadata/metadata.c      |   13 +++++++++++++
 lib/metadata/metadata.h      |    6 ++++++
 3 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7f02fc6..15758d6 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -215,6 +215,7 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 
 	mdal->ops = mda_lists->raw_ops;
 	mdal->metadata_locn = mdac;
+	mdal->flags = 0;
 
 	mdac->area.dev = dev;
 	mdac->area.start = start;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d76a910..68f7436 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3855,6 +3855,19 @@ uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
 	return pv_field(pv, pe_alloc_count);
 }
 
+int mda_is_ignored(struct metadata_area *mda)
+{
+	return (mda->flags & MDA_IGNORED);
+}
+
+void mda_set_ignored(struct metadata_area *mda, int value)
+{
+	if (value)
+		mda->flags |= MDA_IGNORED;
+	else
+		mda->flags &= ~MDA_IGNORED;
+}
+
 uint32_t pv_mda_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 3a3979d..71c562a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -158,12 +158,18 @@ struct metadata_area_ops {
 
 };
 
+#define MDA_IGNORED 0x00000001
+
 struct metadata_area {
 	struct dm_list list;
 	struct metadata_area_ops *ops;
 	void *metadata_locn;
+	uint32_t flags;
 };
 
+int mda_is_ignored(struct metadata_area *mda);
+void mda_set_ignored(struct metadata_area *mda, int value);
+
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
 #define seg_pe(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pe
-- 
1.6.0.6


