From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:13 -0500
Subject: master - pvck: dump show most recent metadata
Message-ID: <02757.119112712211100350@us-mta-405.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d051e899a5ab856da51b9482e3eaf822a73f274d
Commit:        d051e899a5ab856da51b9482e3eaf822a73f274d
Parent:        9cf08836ef42c32de6874e77e1d3003b7b476039
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 4 11:32:23 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

pvck: dump show most recent metadata

---
 tools/pvck.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 483c49f..6e9b10d 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -255,14 +255,18 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 	char vgname[NAME_LEN+1];
 	char id_str[ID_STR_SIZE];
 	char id_first[ID_STR_SIZE];
+	char latest_vgname[NAME_LEN+1];
+	char latest_id_str[ID_STR_SIZE];
 	char *text_buf;
 	char *p;
 	uint32_t buf_off; /* offset with buf which begins with mda_header */
 	uint32_t buf_off_first = 0;
 	uint32_t seqno;
+	uint32_t latest_seqno;
 	uint32_t crc;
 	uint64_t text_size;
 	uint64_t meta_size;
+	uint64_t latest_offset;
 	int metadata_offset_found = 0;
 	int multiple_vgs = 0;
 	int bad_end;
@@ -277,6 +281,11 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		}
 	}
 
+	memset(latest_vgname, 0, sizeof(latest_vgname));
+	memset(latest_id_str, 0, sizeof(latest_id_str));
+	latest_offset = 0;
+	latest_seqno = 0;
+
 	/*
 	 * If metadata has not wrapped, and the metadata area beginning
 	 * has not been damaged, the text area will begin with vgname {.
@@ -419,6 +428,13 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 			  (unsigned long long)text_size,
 			  crc, vgname, seqno, id_str);
 
+		if (!latest_seqno || (seqno > latest_seqno)) {
+			latest_seqno = seqno;
+			latest_offset = mda_offset + buf_off;
+			memcpy(latest_vgname, vgname, NAME_LEN);
+			memcpy(latest_id_str, id_str, ID_STR_SIZE);
+		}
+
 		/*
 		 * save the location of the first metadata we've found so
 		 * we know where to stop after wrapping buf.
@@ -442,7 +458,7 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 				_copy_line(str1, line, &len);
 				log_print("%s", line);
 			}
-			if ((str2 = strstr(str1, "creation_time = "))) {
+			if (str1 && (str2 = strstr(str1, "creation_time = "))) {
 				memset(line, 0, sizeof(line));
 				_copy_line(str2, line, &len);
 				log_print("%s\n", line);
@@ -469,6 +485,12 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 	if (multiple_vgs)
 		log_warn("WARNING: metadata from multiple VGs was found.");
 
+	if (!set->metadata_offset_set)
+		log_print("Most recent metadata found at %llu seqno %u for vg %s id %s",
+			  (unsigned long long)latest_offset, latest_seqno,
+			  latest_vgname, latest_id_str);
+
+
 	if (fp) {
 		if (fflush(fp))
 			stack;



