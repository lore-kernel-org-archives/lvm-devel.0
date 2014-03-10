From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:36:51 +0000 (UTC)
Subject: master - clvmd: fix the len setting in last commit
Message-ID: <20140310113651.B7B9460FA3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c892be4a50049adbaa99c2a8c031a4acb6410f5
Commit:        6c892be4a50049adbaa99c2a8c031a4acb6410f5
Parent:        5dc9402774efb99ffea95d7f5435f36d68aa5077
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 12:35:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:35:44 2014 +0100

clvmd: fix the len setting in last commit

When theoretically sending 0 length buffer, ensure 0 is returned.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 1fc3694..ddebc15 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2002,7 +2002,7 @@ static void send_version_message(void)
 static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext)
 {
-	int len;
+	int len = 0;
 	int ptr;
 	struct timespec delay;
 	struct timespec remtime;


