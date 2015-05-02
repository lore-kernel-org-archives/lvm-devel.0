From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 22:43:45 +0000 (UTC)
Subject: master - clvmd: missed newline in help text
Message-ID: <20150502224345.2AC1D613FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=636bcb020ac54ff26e48592f33cbb7853a24e3e6
Commit:        636bcb020ac54ff26e48592f33cbb7853a24e3e6
Parent:        9fb93fcd901d3ca79293da1257c6f7e618f6c7b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 3 00:30:14 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 00:41:20 2015 +0200

clvmd: missed newline in help text

Print \n after listing included lock managers.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5783df9..43a499e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Add missing newline in clvmd --help output.
 
 Version 2.02.119 - 2nd May 2015
 ===============================
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a7f98a0..6bab3d6 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -172,6 +172,7 @@ static void usage(const char *prog, FILE *file)
 #ifdef USE_SINGLENODE
 		"singlenode "
 #endif
+		"\n"
 		"   -R       Tell all running clvmds in the cluster to reload their device cache\n"
 		"   -S       Restart clvmd, preserving exclusive locks\n"
 		"   -t<secs> Command timeout (default: 60 seconds)\n"


