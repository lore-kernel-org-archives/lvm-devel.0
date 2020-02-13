From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Feb 2020 18:23:39 -0500
Subject: master - thin: don't use writecache for poolmetadata
Message-ID: <16145.120021318233500977@us-mta-111.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db1d66859f8086467979b2d7e32843f70e4436e1
Commit:        db1d66859f8086467979b2d7e32843f70e4436e1
Parent:        cba06012acc589888ef88221f1a580b5b81b4100
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 13 17:22:37 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 13 17:22:37 2020 -0600

thin: don't use writecache for poolmetadata

---
 tools/lvconvert.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index aa2dca7..757b323 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3104,8 +3104,9 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 			return 0;
 		}
 
-		/* FIXME Tidy up all these type restrictions. */
+		/* FIXME Tidy up all these type restrictions. (Use a type whitelist?) */
 		if (lv_is_cache_type(metadata_lv) ||
+		    lv_is_writecache(metadata_lv) ||
 		    lv_is_thin_type(metadata_lv) ||
 		    lv_is_cow(metadata_lv) || lv_is_merging_cow(metadata_lv) ||
 		    lv_is_origin(metadata_lv) || lv_is_merging_origin(metadata_lv) ||



