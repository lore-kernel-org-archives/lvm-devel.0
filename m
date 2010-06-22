From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:40 -0400
Subject: [PATCH 07/35] Ensure in-memory state matches on-disk state of mda ignore bit.
In-Reply-To: <1277175968-9661-7-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |    3 +++
 lib/format_text/text_label.c  |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 577d681..f983c42 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -720,6 +720,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 			  "header at %" PRIu64, vg->name,
 			  dev_name(mdac->area.dev), mdac->area.start);
 
+	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
 		dm_pool_free(fid->fmt->cmd->mem, mdah);
@@ -802,6 +803,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	rlocn->offset = 0;
 	rlocn->size = 0;
 	rlocn->checksum = 0;
+	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 
 	if (!_raw_write_mda_header(fid->fmt, mdac->area.dev, mdac->area.start,
 				   mdah)) {
@@ -1505,6 +1507,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 		mdac = mda->metadata_locn;
 		memset(&buf, 0, sizeof(buf));
 		mdah->size = mdac->area.size;
+		rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
 		if (!_raw_write_mda_header(fmt, mdac->area.dev,
 					   mdac->area.start, mdah)) {
 			if (!dev_close(pv->dev))
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7083b89..ab9f595 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -301,6 +301,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = (struct mda_context *) mda->metadata_locn;
 		if (!dev_open(mdac->area.dev)) {
+			mda_set_ignored(mda, 1);
 			stack;
 			continue;
 		}
@@ -308,6 +309,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 			stack;
 			goto close_dev;
 		}
+		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 		if ((vgname = vgname_from_mda(info->fmt, mdah,
 					      &mdac->area,
-- 
1.6.0.6


