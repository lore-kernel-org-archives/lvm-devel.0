From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:07 +0000 (GMT)
Subject: main - debug: better error message
Message-ID: <20211014213707.6AE1F3858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af0ce203e9f78e307bfb9524dc8377ebbc53e8f1
Commit:        af0ce203e9f78e307bfb9524dc8377ebbc53e8f1
Parent:        7e346ee2a5cd520fc038dda7451360bbe67e629f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 18:44:55 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

debug: better error message

Add more details about size difference.
---
 lib/format_text/format-text.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 654c387bf..941a34944 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1922,7 +1922,9 @@ static int _text_pv_initialise(const struct format_type *fmt,
 		pv->pe_count = pva->extent_count;
 
 	if ((pv->pe_start + pv->pe_count * (uint64_t)pv->pe_size - 1) > pv->size) {
-		log_error("Physical extents end beyond end of device %s.",
+		log_error("Physical extents (%s) end beyond end of device (%s) %s.",
+			  display_size(pv->fmt->cmd, pv->pe_start + pv->pe_count * (uint64_t)pv->pe_size - 1),
+			  display_size(pv->fmt->cmd, pv->size),
 			  pv_dev_name(pv));
 		return 0;
 	}


