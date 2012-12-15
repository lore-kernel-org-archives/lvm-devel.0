From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:02 +0000 (UTC)
Subject: master - cleanup: drop unused header
Message-ID: <20121215162502.207CEAAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b8065a870591e743a79e9aa7f738d084d88bcad
Commit:        8b8065a870591e743a79e9aa7f738d084d88bcad
Parent:        1d774e56670cd8b9d753a8f8a98a3d258e9ee912
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 13 20:35:00 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: drop unused header

This header does not resolve any symbols here.
---
 tools/toollib.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1c455ef..669d772 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -15,7 +15,6 @@
 
 #include "tools.h"
 #include <sys/stat.h>
-#include <strings.h>
 
 const char *command_name(struct cmd_context *cmd)
 {


