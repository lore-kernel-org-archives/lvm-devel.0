From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:58 -0500
Subject: master - lvmlockctl: use inline initilizers
Message-ID: <56095.120020411225101873@us-mta-225.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91d16fc049ba2034708aa6a0bab5f548040dfd3b
Commit:        91d16fc049ba2034708aa6a0bab5f548040dfd3b
Parent:        d01f27f41135189611d2030ec87ff5714eb259af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 29 15:47:40 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

lvmlockctl: use inline initilizers

clang: ensure r_name[] is in all possible paths defined.
---
 daemons/lvmlockd/lvmlockctl.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 40432b5..c2a998c 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -280,13 +280,12 @@ static void format_info_line(char *line, char *r_name, char *r_type)
 
 static void format_info(void)
 {
-	char line[MAX_LINE];
-	char r_name[MAX_NAME+1];
-	char r_type[MAX_NAME+1];
+	char line[MAX_LINE] = { 0 };
+	char r_name[MAX_NAME+1] = { 0 };
+	char r_type[MAX_NAME+1] = { 0 };
 	int i, j;
 
 	j = 0;
-	memset(line, 0, sizeof(line));
 
 	for (i = 0; i < dump_len; i++) {
 		line[j++] = dump_buf[i];



