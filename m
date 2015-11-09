From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:49 +0000 (UTC)
Subject: master - cleanup: drop unneded assign
Message-ID: <20151109092849.966C760BC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c542c18d2af77f3114f22cf3d3845218285a5e62
Commit:        c542c18d2af77f3114f22cf3d3845218285a5e62
Parent:        07046e994fc10882cac20d16666368a6de18a528
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:49:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:51 2015 +0100

cleanup: drop unneded assign

Coverity doesn't really like to see subcommand being assigned NULL,
so drop it.
---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d6c0ad7..15bff64 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6132,7 +6132,7 @@ int main(int argc, char **argv)
 	int ret = 1, r;
 	const char *dev_dir;
 	const struct command *cmd;
-	const char *subcommand = NULL;
+	const char *subcommand;
 	int multiple_devices;
 
 	(void) setlocale(LC_ALL, "");
@@ -6228,7 +6228,7 @@ unknown:
 		subcommand = argv[0];
 		argc--, argv++;
 	} else
-		subcommand = (char *) "";
+		subcommand = "";
 
 	if (_switches[COLS_ARG] && !_report_init(cmd, subcommand))
 		goto_out;


