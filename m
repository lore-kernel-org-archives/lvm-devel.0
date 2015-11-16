From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:08 +0000 (UTC)
Subject: master - format-text: ensure no division by zero
Message-ID: <20151116001708.479B96053A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3b292a4a9924d00da421d66d8281f8cd8efc3a9
Commit:        c3b292a4a9924d00da421d66d8281f8cd8efc3a9
Parent:        193e7f5973e8a0ff7a4f8ebc542fcb9853a30d0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 01:04:21 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

format-text: ensure no division by zero

Coverity likes here to be 100% sure no division by zero is possible.
Add check for alignment !=0 which is made on other code paths here.
---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d4f2c89..58d6209 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2119,7 +2119,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		}
 
 		/* Align MDA0 end position with given alignment offset if possible. */
-		if (alignment_offset &&
+		if (alignment && alignment_offset &&
 		    (((mda_start + mda_size) % alignment) == 0)) {
 			tmp_mda_size = mda_size + alignment_offset;
 			if (mda_start + tmp_mda_size <= limit)


