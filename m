From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:19:04 +0000 (UTC)
Subject: master - cleanup: simplier struct init
Message-ID: <20140819141904.141DA6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5f2c541f6b0ce5d9ef8a1eda66bd021c044e6d2
Commit:        c5f2c541f6b0ce5d9ef8a1eda66bd021c044e6d2
Parent:        24df01f7352e0cf525528000c2026a9a6571b733
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:30:52 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:07 2014 +0200

cleanup: simplier struct init

Use simplier struct initilizer.
---
 tools/dmsetup.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 6cbd21c..f1808c0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -896,13 +896,9 @@ static int _setgeometry(CMD_ARGS)
 
 static int _splitname(CMD_ARGS)
 {
-	struct dmsetup_report_obj obj;
+	struct dmsetup_report_obj obj = { NULL };
 	int r;
 
-	obj.task = NULL;
-	obj.info = NULL;
-	obj.deps_task = NULL;
-	obj.tree_node = NULL;
 	if (!(obj.split_name = _get_split_name((argc == 3) ? argv[2] : "LVM",
 					       argv[1], '\0')))
                 return_0;


