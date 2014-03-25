From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:53:18 +0000 (UTC)
Subject: master - pvresize: fail exit code for negative size
Message-ID: <20140325105318.29C38612AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0738f0ad7289cca4121aace1540e479648a1abe2
Commit:        0738f0ad7289cca4121aace1540e479648a1abe2
Parent:        8471fb01d885aab5c46b61602352ca90814f8a8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 11:52:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:52:03 2014 +0100

pvresize: fail exit code for negative size

Pvresize with negative value retuns invalid cmd line exit code.
---
 WHATS_NEW        |    1 +
 tools/pvresize.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a1eb7ed..6926901 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Return failure when specifying negative size for pvresize.
   Fix memory corruption in cmd context refresh if clvmd leaks opened device.
   Reinitialise lvmcache properly on fork to fix premature polldaemon exit.
   Add 'lvm dumpconfig --type diff' to show differences from defaults.
diff --git a/tools/pvresize.c b/tools/pvresize.c
index faf3134..1bb8a15 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -52,7 +52,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
-		return 0;
+		return EINVALID_CMD_LINE;
 	}
 
 	params.new_size = arg_uint64_value(cmd, physicalvolumesize_ARG,


