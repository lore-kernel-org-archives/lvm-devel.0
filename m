From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:34:12 +0000 (UTC)
Subject: master - man lvmconfig: refer to typeconfig option name
Message-ID: <20170217213412.F29A260E2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50e0345f9d245cdcb29e4988760e788defa5e88e
Commit:        50e0345f9d245cdcb29e4988760e788defa5e88e
Parent:        10cb8e0ec08d430d697fb8a58caaefb5aea32928
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 14:46:10 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 14:46:10 2017 -0600

man lvmconfig: refer to typeconfig option name

---
 tools/args.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 1f3ace7..0575a2f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -546,7 +546,7 @@ arg(shared_ARG, '\0', "shared", 0, 0, 0,
 arg(sinceversion_ARG, '\0', "sinceversion", string_VAL, 0, 0,
     "Specify an LVM version in x.y.z format where x is the major version,\n"
     "the y is the minor version and z is the patchlevel (e.g. 2.2.106).\n"
-    "This option is currently applicable only with --type new\n"
+    "This option is currently applicable only with --typeconfig new\n"
     "to display all configuration settings introduced since given version.\n")
 
 arg(splitcache_ARG, '\0', "splitcache", 0, 0, 0,
@@ -1024,7 +1024,7 @@ arg(list_ARG, 'l', "list", 0, 0, 0,
     "#dumpconfig\n"
     "#config\n"
     "List config settings with summarizing comment. This is the same as using\n"
-    "options --type list --withsummary.\n"
+    "options --typeconfig list --withsummary.\n"
     "#vgcfgrestore\n"
     "List metadata backup and archive files pertaining to the VG.\n"
     "May be used with --file. Does not restore the VG.\n"


