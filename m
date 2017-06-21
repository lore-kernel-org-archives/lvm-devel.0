From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 21 Jun 2017 18:57:42 -0400
Subject: master - mirror: reformat conditional
Message-ID: <201706212257.v5LMvgcZ015593@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2df9a786845af2ce34cb3942dc2b16342e359a2c
Commit:        2df9a786845af2ce34cb3942dc2b16342e359a2c
Parent:        64fac77e8a551f4dfe8f4cfaaf1ca984c9b5146c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jun 22 00:57:16 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jun 22 00:57:16 2017 +0200

mirror: reformat conditional

---
 lib/metadata/mirror.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 9dee0ab..52e1488 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1459,7 +1459,8 @@ int remove_mirrors_from_segments(struct logical_volume *lv,
 			log_error("Segment is not mirrored: %s:%" PRIu32,
 				  lv->name, seg->le);
 			return 0;
-		} if ((seg->status & status_mask) != status_mask) {
+		}
+		if ((seg->status & status_mask) != status_mask) {
 			log_error("Segment status does not match: %s:%" PRIu32
 				  " status:0x%" PRIx64 "/0x%" PRIx64, lv->name, seg->le,
 				  seg->status, status_mask);


