From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jul 2017 12:03:39 -0400
Subject: master - lvm: report error if options are set before command
Message-ID: <201707101603.v6AG3dbi028002@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56768ce36be4a63cda0fec1d06ca061d39288135
Commit:        56768ce36be4a63cda0fec1d06ca061d39288135
Parent:        442d60842d2915f82bd19382b8e08d690243ddd0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 10 11:00:28 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 10 11:02:11 2017 -0500

lvm: report error if options are set before command

Previously, strange parsing errors were reported.
---
 tools/lvmcmdline.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3fa7de5..70371d0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3438,6 +3438,11 @@ int lvm2_main(int argc, char **argv)
 	if (!alias && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")))
 		argv[1] = (char *)"help";
 
+	if (!alias && (*argv[1] == '-')) {
+		log_error("Specify options after a command: lvm [command] [options].");
+		return -1;
+	}
+
 	if (!(cmd = init_lvm(0, 0)))
 		return -1;
 


