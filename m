From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  8 Oct 2015 14:28:14 +0000 (UTC)
Subject: master - metadata: format_text: provide more detailed error message when metadata too large for PV mda
Message-ID: <20151008142814.96354600E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d03e504cda6307f692c5879f6850b2e27af7d71
Commit:        3d03e504cda6307f692c5879f6850b2e27af7d71
Parent:        e04424e87e66df22578d1e4d2488615cd3692873
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 8 16:25:10 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 8 16:27:03 2015 +0200

metadata: format_text: provide more detailed error message when metadata too large for PV mda

Also, leave out the note about "circular buffer" which is
an internal imeplementation detail anyway and not quite
informational for users:

Before this patch:
$ vgcreate vg1 /dev/sda
  VG vg1 metadata too large for circular buffer
  Failed to write VG vg1.

With this patch applied:
$ vgcreate vg1 /dev/sda
  VG vg1 metadata too large: size of metadata to write is 691 bytes while PV metadata area size on /dev/sda is 512 bytes.
  Failed to write VG vg1.
---
 lib/format_text/format-text.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e0ec8ed..c1c4787 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -655,8 +655,11 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if ((new_wrap && old_wrap) ||
 	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
 	    (mdac->rlocn.size >= mdah->size)) {
-		log_error("VG %s metadata too large for circular buffer",
-			  vg->name);
+		log_error("VG %s metadata too large: size of metadata to write "
+			  "is %" PRIu64 " bytes while PV metadata area size "
+			  "on %s is %" PRIu64 " bytes.",
+			   vg->name, mdac->rlocn.size,
+			   dev_name(mdac->area.dev), mdah->size);
 		goto out;
 	}
 


