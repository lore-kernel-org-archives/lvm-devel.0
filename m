From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 08:08:11 +0000 (UTC)
Subject: master - metadata: format_text: better check for metadata overlap
Message-ID: <20151030080811.2AD3A60BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2e88d1107c496d2c1b39bbbfb9795e88b3a6b60
Commit:        c2e88d1107c496d2c1b39bbbfb9795e88b3a6b60
Parent:        406d8ff3323dde6860d88b603701aa4dace47af0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 08:57:34 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 08:57:34 2015 +0100

metadata: format_text: better check for metadata overlap

Actually, we don't need extra condition as introduced in commit
00348c0a630a7e5578edf48052ec695b15de752f. We should fix the last
condition:

  (mdac->rlocn.size >= mdah->size)

...which should be:

  (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size))

Where the "mdac" is new metadata, the "rlocn" is old metadata.

So the main problem with the previous condition was that it
didn't count in MDA_HEADER_SIZE properly (and possible existing
metadata - the "rlocn"). This could have caused the error state
where metadata in ring buffer overlap to not be hit.

Replace the new condition introduced in 00348c0a630a7e5578edf48052ec695b15de752f
with the improved one for the condition that existed there
already but it was just incomplete.
---
 lib/format_text/format-text.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 84d0947..29e9bd2 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -654,8 +654,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	if ((new_wrap && old_wrap) ||
 	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
-	    (!rlocn && new_wrap && (new_end > mdac->rlocn.offset)) ||
-	    (mdac->rlocn.size >= mdah->size)) {
+	    (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)) {
 		log_error("VG %s metadata too large for circular buffer",
 			  vg->name);
 		goto out;


