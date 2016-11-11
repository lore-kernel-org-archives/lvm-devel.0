From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:00 +0000 (UTC)
Subject: master - cleanup: skip checking for just assigned string
Message-ID: <20161111160000.45F7460E40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e54cce245f2829107e1ed09221bca7ff7921d98b
Commit:        e54cce245f2829107e1ed09221bca7ff7921d98b
Parent:        59b29716e5fd0f490d28d2457cdebfc68eb9940e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 18 11:18:02 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:52:24 2016 +0100

cleanup: skip checking for just assigned string

When 'stripe_filler' has been just set to 'error',
do not check it again for not being 'error'.
---
 lib/commands/toolcontext.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c416575..002af05 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -640,8 +640,7 @@ static int _process_config(struct cmd_context *cmd)
 	if (!strcmp(cmd->stripe_filler, "/dev/ioerror") &&
 	    stat(cmd->stripe_filler, &st))
 		cmd->stripe_filler = "error";
-
-	if (strcmp(cmd->stripe_filler, "error")) {
+	else if (strcmp(cmd->stripe_filler, "error")) {
 		if (stat(cmd->stripe_filler, &st)) {
 			log_warn("WARNING: activation/missing_stripe_filler = \"%s\" "
 				 "is invalid,", cmd->stripe_filler);


