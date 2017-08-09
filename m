From: David Teigland <teigland@sourceware.org>
Date: Wed, 9 Aug 2017 10:37:14 -0400
Subject: master - commands: recognize -? for help
Message-ID: <201708091437.v79EbEcI007996@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bc89658476d187a6b1d40018bbbac84d389c5be
Commit:        8bc89658476d187a6b1d40018bbbac84d389c5be
Parent:        8ecb5817c7e08a9a95a0172386af61ba3715948d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 9 09:34:33 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 9 09:34:33 2017 -0500

commands: recognize -? for help

It's not known when this last worked, but there has
been documentation suggesting it worked, so enable it.
---
 tools/lvmcmdline.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 81cc5e0..cc1c297 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3455,8 +3455,8 @@ int lvm2_main(int argc, char **argv)
 		if (!strcmp(argv[1], "version"))
 			return lvm_return_code(version(NULL, argc, argv));
 
-		/* turn 'lvm -h' and 'lvm --help' into 'lvm help' */
-		if (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help"))
+		/* turn 'lvm -h', 'lvm --help', 'lvm -?' into 'lvm help' */
+		if (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help") || !strcmp(argv[1], "-?"))
 			argv[1] = (char *)"help";
 
 		if (*argv[1] == '-') {
@@ -3465,6 +3465,10 @@ int lvm2_main(int argc, char **argv)
 		}
 	}
 
+	/* turn command -? into command -h */
+	if (alias && (argc > 1) && !strcmp(argv[1], "-?"))
+		argv[1] = (char *)"-h";
+
 	if (!(cmd = init_lvm(0, 0)))
 		return EINIT_FAILED;
 


