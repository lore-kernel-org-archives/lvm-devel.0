From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:50 +0000 (GMT)
Subject: main - man-generator: decorate optional option prefixes
Message-ID: <20210419130050.7BFE43969019@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efd0939583484b85ddb8ed3ebb7cda0db51cf473
Commit:        efd0939583484b85ddb8ed3ebb7cda0db51cf473
Parent:        679116a9b859888a893de83236a8966063046f2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 15 20:00:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:37:08 2021 +0200

man-generator: decorate optional option prefixes

Enhance man typography decoration of optional option
prefixes like --[raid]writebeind and use regular font to render []
as these are not part of the option name itself.
---
 tools/command.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/tools/command.c b/tools/command.c
index e776edaa2..556f22e95 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2445,6 +2445,7 @@ static const char *_man_long_opt_name(const char *cmdname, int opt_enum)
 {
 	static char long_opt_name[LONG_OPT_NAME_LEN];
 	const char *long_opt;
+	int i;
 
 	memset(&long_opt_name, 0, sizeof(long_opt_name));
 
@@ -2481,6 +2482,25 @@ static const char *_man_long_opt_name(const char *cmdname, int opt_enum)
 		break;
 	}
 
+	if (strchr(long_opt, '[')) {
+		for (i = 0; i < sizeof(long_opt_name); ++long_opt, ++i) {
+			if (i < (sizeof(long_opt_name) - 8))
+				switch(*long_opt) {
+				case '[':
+					strcpy(long_opt_name + i, "\\fP[\\fB");
+					i += 6;
+					continue;
+				case ']':
+					strcpy(long_opt_name + i, "\\fP]\\fB");
+					i += 6;
+					continue;
+				}
+			long_opt_name[i] = *long_opt;
+		}
+		long_opt_name[i] = 0;
+		return long_opt_name;
+	}
+
 	return long_opt;
 }
 


