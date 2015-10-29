From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Oct 2015 15:47:55 +0000 (UTC)
Subject: master - metadata: format_text: check VG metadata do not overlap themselves
Message-ID: <20151029154755.1E796602A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00348c0a630a7e5578edf48052ec695b15de752f
Commit:        00348c0a630a7e5578edf48052ec695b15de752f
Parent:        ccb8da404d00288b7d49c7a28006ec5d4687bb55
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 29 16:33:06 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 29 16:46:41 2015 +0100

metadata: format_text: check VG metadata do not overlap themselves

We're already checking whether old and new meta do not overlap in
ring buffer (as we need to keep both old and new meta during vg_write
up until vg_commit).

We also need to check whether the new metadata do not overlap
themselves in case we don't have old metadata yet (...because
we're in vgcreate). This could happen if we're creating a VG so
that the very first metadata written are long enough that it wraps
themselves in metadata ring buffer.

Although we limited the minimum metadata area size better with the
previous commit ccb8da404d00288b7d49c7a28006ec5d4687bb55 which
makes the initial VG metadata overlap in ring buffer to be less
probable, the risk of hitting this overlap condition is still there
if we still manage to generate big enough metadata somehow.

For example, users can provide many and/or long VG tags during vgcreate
so that the VG metadata is long enough to start to wrap in the ring
buffer again...
---
 lib/format_text/format-text.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6c653ca..84d0947 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -654,6 +654,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	if ((new_wrap && old_wrap) ||
 	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
+	    (!rlocn && new_wrap && (new_end > mdac->rlocn.offset)) ||
 	    (mdac->rlocn.size >= mdah->size)) {
 		log_error("VG %s metadata too large for circular buffer",
 			  vg->name);


