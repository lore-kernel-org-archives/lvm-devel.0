From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 09:58:34 -0500
Subject: master - pvck: ensure text lines are terminated
Message-ID: <202003041458.024EwYYn015598@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b19b7b6111fb115cd3297e9141a41dfab74ffd2e
Commit:        b19b7b6111fb115cd3297e9141a41dfab74ffd2e
Parent:        f50e7ce76c0c6b2745d0ed2a766f46cea07f310c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 28 11:20:27 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:47:07 2020 -0600

pvck: ensure text lines are terminated

---
 tools/pvck.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index d57e026..a199d73 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -397,7 +397,7 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		 * copy line of possible metadata to check for vgname
 		 */
 		memset(line, 0, sizeof(line));
-		_copy_line(p, line, &len, sizeof(line));
+		_copy_line(p, line, &len, sizeof(line)-1);
 		p += len;
 
 		if (!_check_vgname_start(line, &vgnamelen)) {
@@ -411,7 +411,7 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		 * copy next line of metadata, which should contain id
 		 */
 		memset(line, 0, sizeof(line));
-		_copy_line(p, line, &len, sizeof(line));
+		_copy_line(p, line, &len, sizeof(line)-1);
 		p += len;
 
 		if (strncmp(line, "id = ", 5)) {
@@ -425,7 +425,7 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		 * copy next line of metadata, which should contain seqno
 		 */
 		memset(line, 0, sizeof(line));
-		_copy_line(p, line, &len, sizeof(line));
+		_copy_line(p, line, &len, sizeof(line)-1);
 		p += len;
 
 		if (strncmp(line, "seqno = ", 8)) {
@@ -503,14 +503,14 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 			char *str1, *str2;
 			if ((str1 = strstr(text_buf, "description = "))) {
 				memset(line, 0, sizeof(line));
-				_copy_line(str1, line, &len, sizeof(line));
+				_copy_line(str1, line, &len, sizeof(line)-1);
 				if ((p = strchr(line, '\n')))
 					*p = '\0';
 				log_print("%s", line);
 			}
 			if (str1 && (str2 = strstr(str1, "creation_time = "))) {
 				memset(line, 0, sizeof(line));
-				_copy_line(str2, line, &len, sizeof(line));
+				_copy_line(str2, line, &len, sizeof(line)-1);
 				if ((p = strchr(line, '\n')))
 					*p = '\0';
 				log_print("%s\n", line);
@@ -2481,7 +2481,7 @@ static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
 		memset(line, 0, sizeof(line));
 		len = 0;
 
-		_copy_line(p, line, &len, sizeof(line));
+		_copy_line(p, line, &len, sizeof(line)-1);
 		p += len;
 		back_pos += len;
 
@@ -2507,7 +2507,7 @@ static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
 		len = 0;
 		len2 = 0;
 
-		_copy_line(p, line, &len, sizeof(line));
+		_copy_line(p, line, &len, sizeof(line)-1);
 
 		if (line[0] == '\0')
 			break;



