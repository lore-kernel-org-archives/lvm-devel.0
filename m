From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Jun 2014 16:23:06 +0000 (UTC)
Subject: master - dmsetup: no need to check for "help" field name after report init
Message-ID: <20140619162306.3ACC5610C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59ed4d3bf6b1aaf7c3db837251c60ff9004f0879
Commit:        59ed4d3bf6b1aaf7c3db837251c60ff9004f0879
Parent:        c6d82c992b4a4271287233dbedc3a075fa03ca43
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 19 18:20:30 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 19 18:22:51 2014 +0200

dmsetup: no need to check for "help" field name after report init

The "help" field (as well as "?") is implicit now - libdevmapper
takes care of it completely.
---
 tools/dmsetup.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 454141e..c679c52 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2948,9 +2948,6 @@ static int _report_init(const struct command *cmd)
 	r = 1;
 
 out:
-	if (!strcasecmp(options, "help") || !strcmp(options, "?"))
-		r = 1;
-
 	if (len)
 		dm_free(options);
 


