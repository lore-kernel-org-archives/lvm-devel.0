From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Jun 2013 20:14:11 +0000 (UTC)
Subject: master - cleanup: use parsed yes_no_arg
Message-ID: <20130618201411.C74B860ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d2aa6a7aa6f8208bc27b7f0579e7d85562af2d0
Commit:        4d2aa6a7aa6f8208bc27b7f0579e7d85562af2d0
Parent:        f990b7298d46280d50e2813ea92212a7e595e567
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 17 19:55:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 18 22:13:42 2013 +0200

cleanup: use parsed yes_no_arg

Do not parse yes_no_arg inside tools code and use already
available result as uint.
---
 tools/lvchange.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6e5fd25..d645da6 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -596,7 +596,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 	int active = 0;
 	int32_t major, minor;
 
-	if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "n")) {
+	if (!arg_uint_value(cmd, persistent_ARG, 0)) {
 		if (!(lv->status & FIXED_MINOR)) {
 			log_error("Minor number is already not persistent "
 				  "for \"%s\"", lv->name);


