From: okozina <okozina@fedoraproject.org>
Date: Mon, 13 Apr 2015 18:54:00 +0000 (UTC)
Subject: master - toollib: close connection to lvmetad after fork
Message-ID: <20150413185400.A892F606D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe30658a4d5fe4e4e6bb346c9c9ee7142a98f49d
Commit:        fe30658a4d5fe4e4e6bb346c9c9ee7142a98f49d
Parent:        c26d81d6e6939906729d91fae83cd8bbdd743bb7
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Apr 13 16:29:15 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Apr 13 20:52:32 2015 +0200

toollib: close connection to lvmetad after fork

sharing connection between parent command and background
processes spawned from parent could lead to occasional failures
due to unexpected corruption in daemon responses sent to either child
or a parent.

lvmetad issued warning about duplicate config values in request.
LVM commands occasionaly failed w/ internal error after receving
corrupted response.

lvmetad connection is renewed when needed after explicit disconnect
in child
---
 tools/toollib.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 4856f02..26810b2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -97,6 +97,8 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
+	lvmetad_disconnect();
+
 	if (!skip_lvm) {
 		reset_locking();
 		lvmcache_destroy(cmd, 1, 1);


