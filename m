From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:25 -0500
Subject: master - command: use bigger buffer
Message-ID: <201802282022.w1SKMPUR009781@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=749372caf3e977f2e3f69848e8535fea397695e6
Commit:        749372caf3e977f2e3f69848e8535fea397695e6
Parent:        bc1adc32cbd593dd1839526da82521b429b13141
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 16:57:53 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:08:40 2018 +0100

command: use bigger buffer

Instead of use 'silently' shortened passed string - always
make sure we take either a full copy or return error.
---
 tools/command.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 5a5f351..f974474 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -334,13 +334,15 @@ static char *_split_line(char *buf, int *argc, char **argv, char sep)
 
 static int _val_str_to_num(char *str)
 {
-	char name[32];
+	char name[MAX_LINE_ARGC];
 	char *new;
 	int i;
 
 	/* compare the name before any suffix like _new or _<lvtype> */
 
-	dm_strncpy(name, str, sizeof(name));
+	if (!dm_strncpy(name, str, sizeof(name)))
+		return 0; /* Buffer is too short */
+
 	if ((new = strchr(name, '_')))
 		*new = '\0';
 


