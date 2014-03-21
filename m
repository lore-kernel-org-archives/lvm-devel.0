From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:00 +0000 (UTC)
Subject: master - cleanup: clvmd dump_messages
Message-ID: <20140321213200.F119860F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b79979bb9dde5fd8bc2ef72431e5ce2a5439a3f
Commit:        0b79979bb9dde5fd8bc2ef72431e5ce2a5439a3f
Parent:        f8cd435cd83140e26d35e17f6fbccc1019f67aed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 10:22:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:26 2014 +0100

cleanup: clvmd dump_messages

---
 daemons/clvmd/clvmd.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index bc831d0..a21d53a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1120,30 +1120,27 @@ static int verify_message(char *buf, int len)
 
 static void dump_message(char *buf, int len)
 {
-	unsigned char row[8] = { 0 };
+	unsigned char row[8];
 	char str[9];
-	int i, j, pos = 0;
+	int i, j = 0;
 
+	str[8] = '\0';
 	if (len > 128)
 		len = 128;
 
-	for (i = 0; i < len; i++) {
-		row[pos++] = buf[i];
+	for (i = 0; i < len; ++i) {
+		row[j] = buf[i];
+		str[j] = (isprint(buf[i])) ? buf[i] : ' ';
 
-		if ((pos == 8) || (i + 1 == len)) {
-			memset(str, 0, sizeof(str));
-
-			for (j = 0; j < 8; j++) {
-				if (isprint(row[j]))
-					str[j] = row[j];
-				else
-					str[j] = ' ';
+		if ((j == 8) || (i + 1 == len)) {
+			for (;j < 8; ++j) {
+				row[j] = 0;
+				str[j] = ' ';
 			}
 
 			log_error("%02x %02x %02x %02x %02x %02x %02x %02x [%s]",
 				  row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], str);
-			pos = 0;
-			memset(row, 0, sizeof(row));
+			j = 0;
 		}
 	}
 }


