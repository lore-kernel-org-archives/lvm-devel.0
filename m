From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:31 -0500
Subject: master - cov: fix mem leaking buffer
Message-ID: <72420.119111412072700245@us-mta-323.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d67ce9e140b5691a3f75a69d6e735eec30603670
Commit:        d67ce9e140b5691a3f75a69d6e735eec30603670
Parent:        0bad3977df40a70c68778ff0514d0ca712fee402
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 17:27:14 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: fix mem leaking buffer

Free allocated buffer on function's exit.
Also check for fwrite() results.
---
 tools/pvck.c |   36 ++++++++++++++++++++++--------------
 1 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 1c1bbc2..c197a97 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -662,20 +662,25 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
 			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+		free(meta_buf);
 		return 0;
 	}
 
 	if (!(fp = fopen(tofile, "wx"))) {
-		log_error("Failed to create file %s", tofile);
+		log_error("Failed to create file %s.", tofile);
+		free(meta_buf);
 		return 0;
 	}
 
-	fwrite(meta_buf, mda_size - 512, 1, fp);
+	if (fwrite(meta_buf, mda_size - 512, 1, fp) < (mda_size - 512))
+		log_warn("WARNING: Failed to write " FMTu64 " bytes to file %s.", mda_size - 512, tofile);
 
+	free(meta_buf);
 	if (fflush(fp))
 		stack;
 	if (fclose(fp))
 		stack;
+
 	return 1;
 }
 
@@ -724,7 +729,7 @@ static int _dump_current_text(struct device *dev,
 	 * mda_offset + meta_offset.
 	 */
 	if (meta_offset + meta_size > mda_size) {
-	 	/* text metadata wraps to start of text metadata area */
+		/* text metadata wraps to start of text metadata area */
 		uint32_t wrap = (uint32_t) ((meta_offset + meta_size) - mda_size);
 		off_t offset_a = mda_offset + meta_offset;
 		uint32_t size_a = meta_size - wrap;
@@ -735,6 +740,7 @@ static int _dump_current_text(struct device *dev,
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_a %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_a, (unsigned long long)size_a);
+			free(meta_buf);
 			return 0;
 		}
 
@@ -742,12 +748,14 @@ static int _dump_current_text(struct device *dev,
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_b %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_b, (unsigned long long)size_b);
+			free(meta_buf);
 			return 0;
 		}
 	} else {
 		if (!dev_read_bytes(dev, mda_offset + meta_offset, meta_size, meta_buf)) {
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size);
+			free(meta_buf);
 			return 0;
 		}
 	}
@@ -805,9 +813,9 @@ static int _dump_current_text(struct device *dev,
 	}
 
  out:
-	if (bad)
-		return 0;
-	return 1;
+	free(meta_buf);
+
+	return (!bad) ? 1 : 0;
 }
 
 static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
@@ -851,6 +859,7 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 	if (!dev_read_bytes(dev, lh_offset, 512, buf)) {
 		log_print("CHECK: failed to read label_header at %llu",
 			  (unsigned long long)lh_offset);
+		free(buf);
 		return 0;
 	}
 
@@ -1045,9 +1054,9 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 			  (unsigned long long)xlate64(dlocn->size));
 	}
 
-	if (bad)
-		return 0;
-	return 1;
+	free(buf);
+
+	return (!bad) ? 1 : 0;
 }
 
 /*
@@ -1100,6 +1109,7 @@ static int _dump_mda_header(struct cmd_context *cmd,
 
 	if (!dev_read_bytes(dev, mda_offset, 512, buf)) {
 		log_print("CHECK: failed to read mda_header at %llu", (unsigned long long)mda_offset);
+		free(buf);
 		return 0;
 	}
 
@@ -1190,11 +1200,9 @@ static int _dump_mda_header(struct cmd_context *cmd,
 
 	/* Should we also check text metadata if it exists in rlocn1? */
  out:
-	if (buf)
-		free(buf);
-	if (bad)
-		return 0;
-	return 1;
+	free(buf);
+
+	return (!bad) ? 1 : 0;
 }
 
 static int _dump_headers(struct cmd_context *cmd,



