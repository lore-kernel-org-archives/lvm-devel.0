From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:37:56 -0500
Subject: [PATCH 06/12] Make sure format independent mda disable matches format dependent.
In-Reply-To: <1264801082-28132-6-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-2-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-3-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-4-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-5-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

After reading the label and peering into the text format to get
the vgname and other things, we should set the format independent
mda disable flag.  Similarly, if we are writing the label, we
must make sure the format independent flag sets/clears the
format dependent flag.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |    2 ++
 lib/format_text/text_label.c  |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 344769f..42d2bf9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -557,6 +557,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit);
 	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);
+	mdac_set_disabled(mdac, mda_is_disabled(mda));
 
 	if (!fidtc->raw_metadata_buf &&
 	    !(fidtc->raw_metadata_buf_size =
@@ -1477,6 +1478,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 
 	dm_list_iterate_items(mda, &info->mdas) {
 		mdac = mda->metadata_locn;
+		mdac_set_disabled(mdac, mda_is_disabled(mda));
 		memset(&buf, 0, sizeof(buf));
 		mdah->size = mdac->area.size;
 		mdah->raw_locns[0].flags = mdac->rlocn.flags;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e7a58cf..d04fac5 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -307,6 +307,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 						   (char *) &vgid, vgstatus,
 						   creation_host))
 			return_0;
+		mda_set_disabled(mda, mdac_is_disabled(mdac));
 	}
 
 	info->status &= ~CACHE_INVALID;
-- 
1.6.0.6


