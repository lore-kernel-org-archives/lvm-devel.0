From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:13 +0000 (UTC)
Subject: master - pvchange: fix exit code regression
Message-ID: <20140327121513.5F2AB6196E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80fe100afa3bb2cbbc81bb4517a762159f0ebe65
Commit:        80fe100afa3bb2cbbc81bb4517a762159f0ebe65
Parent:        2a93eba68e518fff7f0c16406b5a9e802d732e1d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 11:27:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:01:51 2014 +0100

pvchange: fix exit code regression

Commit 1a832398a7caa96faab2ccbac773cc4047c8f9c1 moved
some code from _pvchange_single() to main pvchange() and
introduced exit code regression as return codes have not
been properly changed, thus pvchange command exited
with '0' exit code, even though it has reported error.
Also there is a missing vg unlock in error path.

Fix it by counting the total number of expected calls before
checking for pvname and also unlock and relase vg when
pv is not found.
---
 WHATS_NEW        |    1 +
 tools/pvchange.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e6fa1d7..a9289b5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix exit code regression in failing pvchange command (2.02.66).
   Include 'lvm dumpconfig --type missing' and '--type diff' output to lvmdump.
   Return failure when specifying negative size for pvresize.
   Fix memory corruption in cmd context refresh if clvmd leaks opened device.
diff --git a/tools/pvchange.c b/tools/pvchange.c
index d2a3d9b..5c05db6 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -184,6 +184,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
+			total++;
 			pv_name = argv[opt];
 			dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
 			vg_name = find_vgname_from_pvname(cmd, pv_name);
@@ -200,12 +201,12 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			}
 			pvl = find_pv_in_vg(vg, pv_name);
 			if (!pvl || !pvl->pv) {
+				unlock_and_release_vg(cmd, vg, vg_name);
 				log_error("Unable to find %s in %s",
 					  pv_name, vg_name);
 				continue;
 			}
 
-			total++;
 			done += _pvchange_single(cmd, vg,
 						 pvl->pv, NULL);
 			unlock_and_release_vg(cmd, vg, vg_name);


