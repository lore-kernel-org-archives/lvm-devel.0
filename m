From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Oct 2012 09:03:38 +0000 (UTC)
Subject: master - lvmetad: empty types string is ok
Message-ID: <20121015090338.D2CC5A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ed2c32e0a8f36c6d5da347b5367aa16d52245aa
Commit:        3ed2c32e0a8f36c6d5da347b5367aa16d52245aa
Parent:        a0e60d27ff91c46a1febf58a955c6b88539ba982
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 11:02:15 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 11:02:15 2012 +0200

lvmetad: empty types string is ok

Since now return code is test - return OK for this case.
---
 libdaemon/server/daemon-log.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 1e1c9e0..6f5f4dc 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -153,12 +153,16 @@ static int _parse_one(log_state *s, int outlet, const char *type, int enable)
 
 int daemon_log_parse(log_state *s, int outlet, const char *types, int enable)
 {
-	char *buf = dm_strdup(types);
-	char *pos = buf;
+	char *buf;
+	char *pos;
 
-	if (!buf)
+	if (!types || !types[0])
+		return 1;
+
+	if (!(buf = dm_strdup(types)))
 		return 0;
 
+	pos = buf;
 	while (pos) {
 		char *next = strchr(pos, ',');
 		if (next)


