From: David Teigland <teigland@sourceware.org>
Date: Wed, 9 Aug 2017 16:07:36 -0400
Subject: master - commands: recognize lvm command -?
Message-ID: <201708092007.v79K7aS4001581@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=955083e625eb003090ce8f699e8d414a215cce1f
Commit:        955083e625eb003090ce8f699e8d414a215cce1f
Parent:        8bc89658476d187a6b1d40018bbbac84d389c5be
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 9 15:06:36 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 9 15:06:36 2017 -0500

commands: recognize lvm command -?

and interpret it as lvm command -h
---
 tools/lvmcmdline.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index cc1c297..55f72ac 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3465,9 +3465,11 @@ int lvm2_main(int argc, char **argv)
 		}
 	}
 
-	/* turn command -? into command -h */
+	/* turn command -? into command -h and lvm command -? into lvm command -h */
 	if (alias && (argc > 1) && !strcmp(argv[1], "-?"))
 		argv[1] = (char *)"-h";
+	if (!alias && (argc > 2) && !strcmp(argv[2], "-?"))
+		argv[2] = (char *)"-h";
 
 	if (!(cmd = init_lvm(0, 0)))
 		return EINIT_FAILED;


