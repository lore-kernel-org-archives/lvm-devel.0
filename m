From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:45:56 +0000 (UTC)
Subject: master - pvdisplay: fix option error
Message-ID: <20140330214556.04A5D602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=844afa32a0d980d0bf09ae1663f010d9e1a12839
Commit:        844afa32a0d980d0bf09ae1663f010d9e1a12839
Parent:        cf29de5de0a39ade491e18c1fe0e8bd3c2937b08
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 23:12:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:41:52 2014 +0200

pvdisplay: fix option error

Properly show error for '-m'.
Also report unsupported  '-c & -s' (just like with vg/lvdisplay)
---
 WHATS_NEW         |    1 +
 tools/pvdisplay.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dc0d1b4..542b802 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix error message for pvdisplay -c -m and add new for pvdisplay -c -s.
   Return proper invalid cmd when vgimport/exports find error in parameters.
   Obtain list of known VGs for pvchange --all when using lvmetad.
   Add man page for lvm dumpconfig.
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 34ec3d5..b85635e 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -109,7 +109,12 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_count(cmd, colon_ARG) && arg_count(cmd, maps_ARG)) {
-		log_error("Option -v not allowed with option -c");
+		log_error("Option -c not allowed with option -m");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, colon_ARG) && arg_count(cmd, short_ARG)) {
+		log_error("Option -c is not allowed with option -s");
 		return EINVALID_CMD_LINE;
 	}
 


