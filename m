From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 16:53:33 +0000 (UTC)
Subject: master - reporter: drop mem on error path
Message-ID: <20141113165333.BDCE8601FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49e3fd1ce8d0b1023f553673e76b49e65348878f
Commit:        49e3fd1ce8d0b1023f553673e76b49e65348878f
Parent:        6308a8b06d4dd52e9a8e95bb0ec1933eee547ee4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 17:39:22 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 17:44:31 2014 +0100

reporter: drop mem on error path

Coverity noticed.
---
 tools/reporter.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 24191f1..8399395 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -553,6 +553,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 			log_error("Unable to obtain global lock.");
+			dm_report_free(report_handle);
 			return ECMD_FAILED;
 		}
 	}


