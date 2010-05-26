From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 26 May 2010 10:02:16 -0400
Subject: [PATCH 14/18] Implement ignore of mda if bit set by skipping r/w of metadata.
In-Reply-To: <1274882540-6181-14-git-send-email-dwysocha@redhat.com>
References: <1274882540-6181-1-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-2-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-3-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-4-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-5-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-6-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-7-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-8-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-9-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-10-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-11-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-12-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-13-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-14-git-send-email-dwysocha@redhat.com>
Message-ID: <1274882540-6181-15-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We implement ignore of an mda at label_read time by checking for
the ignore bit, and then skipping the reading of the vgname and
other information in the metadata.  This will have an effect similar
to a PV found with no mdas.  Thus, it will look like an orphan in the
cache until we scan the rest of the system and find a PV with
metadata, and the mda will not be on the vg->fid->metadata_areas
list so no read/writes will be done to the metadata area.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/text_label.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index ab9f595..70aba3f 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -311,6 +311,12 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		}
 		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
+		if (mda_is_ignored(mda)) {
+			if (!dev_close(mdac->area.dev))
+				stack;
+			continue;
+		}
+
 		if ((vgname = vgname_from_mda(info->fmt, mdah,
 					      &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
-- 
1.6.0.6


