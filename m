From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 12:34:20 -0500
Subject: master - pvck: use dm_config_parse_without_dup_node_check
Message-ID: <202003041734.024HYKSa028361@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=caecbcbeac633c6f1f09edb18916830d3020db36
Commit:        caecbcbeac633c6f1f09edb18916830d3020db36
Parent:        4b5bfa779a744b3ad3b3d28dcb6797110a39dbab
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 4 11:32:13 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 4 11:32:13 2020 -0600

pvck: use dm_config_parse_without_dup_node_check

instead of dm_config_parse.  Some strange case could
cause dm_config_parse to print duplicate warnings about
all the metadata fileds.
---
 tools/pvck.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 566dfc3..71bfc1b 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -258,7 +258,7 @@ static int _text_buf_parse(char *text_buf, uint64_t text_size, struct dm_config_
 		return 0;
 	}
 
-	if (!dm_config_parse(cft, text_buf, text_buf + text_size)) {
+	if (!dm_config_parse_without_dup_node_check(cft, text_buf, text_buf + text_size)) {
 		config_destroy(cft);
 		return 0;
 	}
@@ -952,7 +952,7 @@ static int _dump_current_text(struct device *dev, struct devicefile *def,
 		log_print("CHECK: failed to set up metadata parsing");
 		bad++;
 	} else {
-		if (!dm_config_parse(cft, meta_buf, meta_buf + meta_size)) {
+		if (!dm_config_parse_without_dup_node_check(cft, meta_buf, meta_buf + meta_size)) {
 			log_print("CHECK: failed to parse metadata text at %llu size %llu",
 				  (unsigned long long)(mda_offset + meta_offset),
 				   (unsigned long long)meta_size);



