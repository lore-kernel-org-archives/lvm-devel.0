From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 17 Aug 2015 17:37:32 +0000 (UTC)
Subject: master - dmsetup: make sure subcommand is initialised (Coverity)
Message-ID: <20150817173732.2A7B860139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b01e9651b06a6362339d4c3d5d8da43896dae50f
Commit:        b01e9651b06a6362339d4c3d5d8da43896dae50f
Parent:        8967776713e1be2d584bc8a9713eaaaf467d8ac7
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 18:28:32 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 17 18:37:16 2015 +0100

dmsetup: make sure subcommand is initialised (Coverity)

---
 tools/dmsetup.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index dc002b0..8bcf4d5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5964,7 +5964,8 @@ unknown:
 	if (cmd->has_subcommands) {
 		subcommand = argv[0];
 		argc--, argv++;
-	}
+	} else
+		subcommand = (char *) "";
 
 	if (_switches[COLS_ARG] && !_report_init(cmd, subcommand))
 		goto out;


