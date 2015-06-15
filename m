From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jun 2015 12:48:35 +0000 (UTC)
Subject: master - dmeventd: drop stack
Message-ID: <20150615124835.745FE601A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d5f7f90c882e0f7bfa8cafb87ce3db4ea91e4a0
Commit:        3d5f7f90c882e0f7bfa8cafb87ce3db4ea91e4a0
Parent:        9da07f1d3ef40c982d463a97cf6aaf65f813ebc8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 15 14:38:44 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 15 14:46:44 2015 +0200

dmeventd: drop stack

---
 daemons/dmeventd/dmeventd.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index d452f84..9fb3af7 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1671,10 +1671,8 @@ static void _cleanup_unused_threads(void)
 				if (ret == ESRCH) {
 					thread->status = DM_THREAD_DONE;
 				} else if (ret) {
-					syslog(LOG_ERR,
-					       "Unable to terminate thread: %s\n",
-					       strerror(-ret));
-					stack;
+					syslog(LOG_ERR, "Unable to terminate thread: %s",
+					       strerror(ret));
 				}
 				break;
 			}


