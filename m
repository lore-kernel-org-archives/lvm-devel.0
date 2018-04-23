From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:54 -0400
Subject: master - pvck: use bcache
Message-ID: <201804231350.w3NDostX032019@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7670d333855ecccb21b30bc6b4525d6bafaa940
Commit:        e7670d333855ecccb21b30bc6b4525d6bafaa940
Parent:        b504bb809efa8a3a4db0e494bb80d3720d82e6ff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 15 11:06:50 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

pvck: use bcache

---
 lib/format_text/format-text.c |   24 +++++++++++++++++-------
 tools/pvck.c                  |    2 ++
 2 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 8a42213..ef59f07 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -187,9 +187,6 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		  FMTu64, mdac->area.start, mdac->area.size);
 	area = &mdac->area;
 
-	if (!dev_open_readonly(area->dev))
-		return_0;
-
 	if (!(mdah = raw_read_mda_header(fmt, area, mda_is_primary(mda))))
 		goto_out;
 
@@ -230,8 +227,23 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		if (!(buf = dm_malloc(size + size2)))
 			goto_out;
 
-		if (!dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
-			goto_out;
+		if (!bcache_read_bytes(scan_bcache, area->dev->bcache_fd, offset, size, buf)) {
+			log_error("Failed to read dev %s offset %llu size %llu",
+				  dev_name(area->dev),
+				  (unsigned long long)offset,
+				  (unsigned long long)size);
+			goto out;
+		}
+
+		if (size2) {
+			if (!bcache_read_bytes(scan_bcache, area->dev->bcache_fd, offset2, size2, buf + size)) {
+				log_error("Failed to read dev %s offset %llu size %llu",
+				  	  dev_name(area->dev),
+					  (unsigned long long)offset2,
+				          (unsigned long long)size2);
+				goto out;
+			}
+		}
 
 		/*
 		 * FIXME: We could add more sophisticated metadata detection
@@ -268,8 +280,6 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	r = 1;
  out:
 	dm_free(buf);
-	if (!dev_close(area->dev))
-		stack;
 	return r;
 }
 
diff --git a/tools/pvck.c b/tools/pvck.c
index 0fedb4a..634b38d 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -23,6 +23,8 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	/* FIXME: validate cmdline options */
 	/* FIXME: what does the cmdline look like? */
 
+	label_scan_setup_bcache();
+
 	/*
 	 * Use what's on the cmdline directly, and avoid calling into
 	 * some of the other infrastructure functions, so as to avoid


