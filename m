From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:45:58 +0000 (UTC)
Subject: master - pvscan: return error when free parameter is given
Message-ID: <20140330214558.19FAD602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a9c569eb41f48b32c32dd29f8f36add09e95e30
Commit:        7a9c569eb41f48b32c32dd29f8f36add09e95e30
Parent:        844afa32a0d980d0bf09ae1663f010d9e1a12839
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 23:32:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:42:57 2014 +0200

pvscan: return error when free parameter is given

Just like vgscan, pvscan (without --cache option) is not
accepting and 'free' args  (i.e.  pvscan /dev/sdx)
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 542b802..3368c9d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Report error when running pvscan with free argument (i.e. PV name).
   Fix error message for pvdisplay -c -m and add new for pvdisplay -c -s.
   Return proper invalid cmd when vgimport/exports find error in parameters.
   Obtain list of known VGs for pvchange --all when using lvmetad.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 724ae5f..ae14878 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -334,6 +334,11 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, cache_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
 
+	if (argc) {
+		log_error("Too many parameters on command line.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (arg_count(cmd, activate_ARG)) {
 		log_error("--activate is only valid with --cache.");
 		return EINVALID_CMD_LINE;


