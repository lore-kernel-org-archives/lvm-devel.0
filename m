From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Oct 2015 10:11:11 +0000 (UTC)
Subject: master - revert: 3d03e504cda6307f692c5879f6850b2e27af7d71: message about VG metadata size vs. PV mda size
Message-ID: <20151029101111.F063760F1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3c81d02c974eda1c33afd88517d899e64aea24e
Commit:        b3c81d02c974eda1c33afd88517d899e64aea24e
Parent:        5886ff64ebcac8c1b53c665c598728e481590964
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 29 11:08:28 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 29 11:10:48 2015 +0100

revert: 3d03e504cda6307f692c5879f6850b2e27af7d71: message about VG metadata size vs. PV mda size

The message needs refinement - it's not correct in all situations.
---
 lib/format_text/format-text.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c1c4787..e0ec8ed 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -655,11 +655,8 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if ((new_wrap && old_wrap) ||
 	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
 	    (mdac->rlocn.size >= mdah->size)) {
-		log_error("VG %s metadata too large: size of metadata to write "
-			  "is %" PRIu64 " bytes while PV metadata area size "
-			  "on %s is %" PRIu64 " bytes.",
-			   vg->name, mdac->rlocn.size,
-			   dev_name(mdac->area.dev), mdah->size);
+		log_error("VG %s metadata too large for circular buffer",
+			  vg->name);
 		goto out;
 	}
 


