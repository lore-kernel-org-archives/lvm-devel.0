From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 11 Dec 2017 16:00:34 -0500
Subject: master - format_text: Use absolute alignment to calculate metadata usage
Message-ID: <201712112100.vBBL0YZn008025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=053d35de473aafe641f595b1182626ea39fc0ab0
Commit:        053d35de473aafe641f595b1182626ea39fc0ab0
Parent:        2db67a8ea09a6f1073583e135bfb7b66228d3526
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 11 17:14:38 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 11 17:14:38 2017 +0000

format_text: Use absolute alignment to calculate metadata usage

Currently both start and offset should always be divisible by alignment,
so this should have no effect, but a later patch will increase alignment
so these variables can no longer be optimised out.
---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 881fd4d..c226131 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1292,7 +1292,7 @@ int vgname_from_mda(const struct format_type *fmt,
 			   (char *)&vgsummary->vgid);
 
 	if (mda_free_sectors) {
-		current_usage = ALIGN_ABSOLUTE(rlocn->size, 0, MDA_ORIGINAL_ALIGNMENT);
+		current_usage = ALIGN_ABSOLUTE(rlocn->size, dev_area->start + rlocn->offset, MDA_ORIGINAL_ALIGNMENT);
 
 		buffer_size = mdah->size - MDA_HEADER_SIZE;
 


