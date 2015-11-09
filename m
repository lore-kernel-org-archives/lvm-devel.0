From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 11:29:05 +0000 (UTC)
Subject: master - dmsetup: cleanup warn for older compilers
Message-ID: <20151109112905.537C16092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84a954686903b705eb0733a1bc02a7ac66728779
Commit:        84a954686903b705eb0733a1bc02a7ac66728779
Parent:        5aae8de7760e321ad1fd6e88128379640df31c29
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 10:48:40 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 12:21:17 2015 +0100

dmsetup: cleanup warn for older compilers

Older gcc somehow thinks there is a path of using
subcommand uninitilized.

So make it more obvious there is no such one.
---
 tools/dmsetup.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 15bff64..bfba753 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6132,7 +6132,7 @@ int main(int argc, char **argv)
 	int ret = 1, r;
 	const char *dev_dir;
 	const struct command *cmd;
-	const char *subcommand;
+	const char *subcommand = "";
 	int multiple_devices;
 
 	(void) setlocale(LC_ALL, "");
@@ -6227,8 +6227,7 @@ unknown:
 	if (cmd->has_subcommands) {
 		subcommand = argv[0];
 		argc--, argv++;
-	} else
-		subcommand = "";
+	}
 
 	if (_switches[COLS_ARG] && !_report_init(cmd, subcommand))
 		goto_out;


