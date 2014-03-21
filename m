From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:54 +0000 (UTC)
Subject: master - cleanup: clvmd skip reset of null pointer
Message-ID: <20140321213154.B51D160F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d49c33ffc41d58bd17ab032df23ca1a08f017b9
Commit:        7d49c33ffc41d58bd17ab032df23ca1a08f017b9
Parent:        bf19c6be2c57c43ebc6c7ceb85fd7487c7e36799
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 23:37:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:25 2014 +0100

cleanup: clvmd skip reset of null pointer

---
 daemons/clvmd/lvm-functions.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index fb3a95c..e523522 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -917,6 +917,6 @@ void destroy_lvm(void)
 	if (cmd) {
 		memlock_dec_daemon(cmd);
 		destroy_toolcontext(cmd);
+		cmd = NULL;
 	}
-	cmd = NULL;
 }


