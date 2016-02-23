From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:28 +0000 (UTC)
Subject: master - coverity: check cmd pointer exists
Message-ID: <20160223204128.4531E6055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9634e993a44760e164f0ed12aaeaa6903cc9a6e
Commit:        a9634e993a44760e164f0ed12aaeaa6903cc9a6e
Parent:        68955a81024d43138ee29b682d08233baf5ee876
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 21:02:36 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:16 2016 +0100

coverity: check cmd pointer exists

Since in _report_init() we check few times for cmd != NULL
keep it consistent and Coverity happier.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4db6004..b61b42f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4384,7 +4384,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 				selection, NULL, NULL)))
 		goto_out;
 
-	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {
+	if ((_report_type & DR_TREE) && cmd && !_build_whole_deptree(cmd)) {
 		err("Internal device dependency tree creation failed.");
 		goto out;
 	}


