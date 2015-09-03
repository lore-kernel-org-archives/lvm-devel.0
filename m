From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:17 +0000 (UTC)
Subject: master - lvcreate: restore missed --monitor
Message-ID: <20150903213617.C3CFE60F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20e317cf92d0760c8e1052dc975a14645aecfd84
Commit:        20e317cf92d0760c8e1052dc975a14645aecfd84
Parent:        2b9843c20b3ca26867228d89154b611c4464eff2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 27 17:19:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

lvcreate: restore missed --monitor

Fix regression from d13239b0547e09def4b58b0f49bd0252f459d431.
This patch reorganized whole command option parsing, however
it has lost support to accept --monitor arg.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6336f45..887fafd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.130 - 
 ===================================
+  Restore support for --monitor option in lvcreate (2.02.112).
   Read thin-pool data and metadata percent without flush.
   Detect blocked thin-pool and avoid scanning their thin volumes.
   Check if dm device is usable before checking its size (2.02.116).
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2a94f3b..364a16a 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -700,6 +700,7 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	contiguous_ARG,\
 	ignoreactivationskip_ARG,\
 	ignoremonitoring_ARG,\
+	monitor_ARG,\
 	mirrors_ARG,\
 	name_ARG,\
 	noudevsync_ARG,\


