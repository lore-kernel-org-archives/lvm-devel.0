From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:48 -0500
Subject: master - hints: validate allocation result
Message-ID: <76569.119111412074301373@us-mta-32.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1349a52626610abc6bfc20871e592c050048380d
Commit:        1349a52626610abc6bfc20871e592c050048380d
Parent:        219fe7235922cdcd559138def0a46a48ceaf528e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 18:00:00 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

hints: validate allocation result

---
 lib/label/hints.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 09f12de..df1327a 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1175,7 +1175,8 @@ static void _get_single_vgname_cmd_arg(struct cmd_context *cmd,
 
 	if (!(st = strchr(arg, '/'))) {
 		/* simple vgname */
-		name = strdup(arg);
+		if (!(name = strdup(arg)))
+			return;
 		goto check;
 	}
 
@@ -1183,7 +1184,8 @@ static void _get_single_vgname_cmd_arg(struct cmd_context *cmd,
 	for (p = arg; p < st; p++)
 		namebuf[i++] = *p;
 
-	name = strdup(namebuf);
+	if (!(name = strdup(namebuf)))
+		return;
 
 check:
 	/*



