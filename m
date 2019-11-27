From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:20:46 -0500
Subject: master - Revert "cov: fix mem leaking buffer"
Message-ID: <29908.119112712204400809@us-mta-68.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4485b8edca559e9c45311f2a3b88d03bd3223834
Commit:        4485b8edca559e9c45311f2a3b88d03bd3223834
Parent:        657d42e87953adcecc37701ee4e04287c30eec96
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:31:29 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:36 2019 -0600

Revert "cov: fix mem leaking buffer"

This reverts commit d67ce9e140b5691a3f75a69d6e735eec30603670.

fixes folded into subsequent pvck commit
---
 tools/pvck.c |   36 ++++++++++++++----------------------
 1 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 90bcafe..c6f6a33 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -658,25 +658,20 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
 			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
-		free(meta_buf);
 		return 0;
 	}
 
 	if (!(fp = fopen(tofile, "wx"))) {
-		log_error("Failed to create file %s.", tofile);
-		free(meta_buf);
+		log_error("Failed to create file %s", tofile);
 		return 0;
 	}
 
-	if (fwrite(meta_buf, mda_size - 512, 1, fp) < (mda_size - 512))
-		log_warn("WARNING: Failed to write " FMTu64 " bytes to file %s.", mda_size - 512, tofile);
+	fwrite(meta_buf, mda_size - 512, 1, fp);
 
-	free(meta_buf);
 	if (fflush(fp))
 		stack;
 	if (fclose(fp))
 		stack;
-
 	return 1;
 }
 
@@ -724,7 +719,7 @@ static int _dump_current_text(struct device *dev,
 	 * mda_offset + meta_offset.
 	 */
 	if (meta_offset + meta_size > mda_size) {
-		/* text metadata wraps to start of text metadata area */
+	 	/* text metadata wraps to start of text metadata area */
 		uint32_t wrap = (uint32_t) ((meta_offset + meta_size) - mda_size);
 		off_t offset_a = mda_offset + meta_offset;
 		uint32_t size_a = meta_size - wrap;
@@ -735,7 +730,6 @@ static int _dump_current_text(struct device *dev,
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_a %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_a, (unsigned long long)size_a);
-			free(meta_buf);
 			return 0;
 		}
 
@@ -743,14 +737,12 @@ static int _dump_current_text(struct device *dev,
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_b %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_b, (unsigned long long)size_b);
-			free(meta_buf);
 			return 0;
 		}
 	} else {
 		if (!dev_read_bytes(dev, mda_offset + meta_offset, meta_size, meta_buf)) {
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size);
-			free(meta_buf);
 			return 0;
 		}
 	}
@@ -808,9 +800,9 @@ static int _dump_current_text(struct device *dev,
 	}
 
  out:
-	free(meta_buf);
-
-	return (!bad) ? 1 : 0;
+	if (bad)
+		return 0;
+	return 1;
 }
 
 static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
@@ -854,7 +846,6 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 	if (!dev_read_bytes(dev, lh_offset, 512, buf)) {
 		log_print("CHECK: failed to read label_header at %llu",
 			  (unsigned long long)lh_offset);
-		free(buf);
 		return 0;
 	}
 
@@ -1049,9 +1040,9 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 			  (unsigned long long)xlate64(dlocn->size));
 	}
 
-	free(buf);
-
-	return (!bad) ? 1 : 0;
+	if (bad)
+		return 0;
+	return 1;
 }
 
 /*
@@ -1104,7 +1095,6 @@ static int _dump_mda_header(struct cmd_context *cmd,
 
 	if (!dev_read_bytes(dev, mda_offset, 512, buf)) {
 		log_print("CHECK: failed to read mda_header at %llu", (unsigned long long)mda_offset);
-		free(buf);
 		return 0;
 	}
 
@@ -1195,9 +1185,11 @@ static int _dump_mda_header(struct cmd_context *cmd,
 
 	/* Should we also check text metadata if it exists in rlocn1? */
  out:
-	free(buf);
-
-	return (!bad) ? 1 : 0;
+	if (buf)
+		free(buf);
+	if (bad)
+		return 0;
+	return 1;
 }
 
 static int _dump_headers(struct cmd_context *cmd,



