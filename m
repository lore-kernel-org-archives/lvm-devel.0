From: David Teigland <teigland@sourceware.org>
Date: Wed, 4 Mar 2020 09:58:34 -0500
Subject: master - pvck: print longer command description
Message-ID: <202003041458.024EwYDw015597@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b79673845496402d9614784e8b08dbd284328ae
Commit:        1b79673845496402d9614784e8b08dbd284328ae
Parent:        b19b7b6111fb115cd3297e9141a41dfab74ffd2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 28 11:24:28 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 3 13:47:07 2020 -0600

pvck: print longer command description

---
 tools/pvck.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index a199d73..745f0f9 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -280,6 +280,9 @@ static int _text_buf_parsable(char *text_buf, uint64_t text_size)
 
 #define MAX_LINE_CHECK 128
 
+#define MAX_DESC 1024
+char desc_line[MAX_DESC];
+
 static void _copy_line(char *in, char *out, int *len, int linesize)
 {
 	int i;
@@ -502,18 +505,18 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		if (arg_is_set(cmd, verbose_ARG)) {
 			char *str1, *str2;
 			if ((str1 = strstr(text_buf, "description = "))) {
-				memset(line, 0, sizeof(line));
-				_copy_line(str1, line, &len, sizeof(line)-1);
-				if ((p = strchr(line, '\n')))
+				memset(desc_line, 0, sizeof(desc_line));
+				_copy_line(str1, desc_line, &len, sizeof(desc_line)-1);
+				if ((p = strchr(desc_line, '\n')))
 					*p = '\0';
-				log_print("%s", line);
+				log_print("%s", desc_line);
 			}
 			if (str1 && (str2 = strstr(str1, "creation_time = "))) {
-				memset(line, 0, sizeof(line));
-				_copy_line(str2, line, &len, sizeof(line)-1);
-				if ((p = strchr(line, '\n')))
+				memset(desc_line, 0, sizeof(desc_line));
+				_copy_line(str2, desc_line, &len, sizeof(desc_line)-1);
+				if ((p = strchr(desc_line, '\n')))
 					*p = '\0';
-				log_print("%s\n", line);
+				log_print("%s\n", desc_line);
 			}
 		}
 



