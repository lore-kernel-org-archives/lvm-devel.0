From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:24:59 +0000 (UTC)
Subject: master - cleanup: drop test for optarg NULL
Message-ID: <20121215162459.B61D4AAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d774e56670cd8b9d753a8f8a98a3d258e9ee912
Commit:        1d774e56670cd8b9d753a8f8a98a3d258e9ee912
Parent:        03be45ac0a3b10807374ac0869ac8431bee348b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 13 19:54:07 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: drop test for optarg NULL

Since -d takes an argument, we do not need to check for
optarg being NULL here.
---
 daemons/clvmd/clvmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index eb0bffd..398e1a4 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -385,7 +385,7 @@ int main(int argc, char *argv[])
 
 		case 'd':
 			debug_opt = DEBUG_STDERR;
-			debug_arg = optarg ? (debug_t) atoi(optarg) : DEBUG_STDERR;
+			debug_arg = (debug_t) atoi(optarg);
 			if (debug_arg == DEBUG_STDERR)
 				foreground_mode = 1;
 			break;


