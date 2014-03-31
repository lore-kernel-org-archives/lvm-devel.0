From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:36 +0000 (UTC)
Subject: master - lvdiplay: prohibit use of -c and -m
Message-ID: <20140331100636.5937960AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=caa429da2e58ad65ecfc8836f5f64c54395a8793
Commit:        caa429da2e58ad65ecfc8836f5f64c54395a8793
Parent:        8f9150c241f80b2fd69d2e416340707759e79ac8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 10:04:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:00:45 2014 +0200

lvdiplay: prohibit use of -c and -m

It's unclear why we should prohibit use of -v output.
So reenable (like with other 'display' tools)
But -c -m is really unsupported - return invalid cmd.
---
 WHATS_NEW         |    1 +
 tools/lvdisplay.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0decc72..b5ee541 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Add explict error message when using lvdisplay -c -m.
   Update man pages for pv/vg/lvdisplay.
   Report error when running pvscan with free argument (i.e. PV name).
   Fix error message for pvdisplay -c -m and add new for pvdisplay -c -s.
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index f5531cb..246e43b 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -49,8 +49,8 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, colon_ARG) && arg_count(cmd, verbose_ARG)) {
-		log_error("Options -v and -c are incompatible");
+	if (arg_count(cmd, colon_ARG) && arg_count(cmd, maps_ARG)) {
+		log_error("Options -c and -m are incompatible.");
 		return EINVALID_CMD_LINE;
 	}
 


