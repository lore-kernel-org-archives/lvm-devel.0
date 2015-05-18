From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:33 +0000 (UTC)
Subject: master - makefiles: drop LVM_SHARED_PATH
Message-ID: <20150518105233.826FE61057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62ac80c8fad09fb14f27d56663a5377948e20fce
Commit:        62ac80c8fad09fb14f27d56663a5377948e20fce
Parent:        30c3bbcd9e852d7f79846ecc57148a47e52e818d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 12:16:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:45:42 2015 +0200

makefiles: drop LVM_SHARED_PATH

We already have LVM_PATH define used everywhere else
to access LVM binary so stay with one name.
---
 tools/Makefile.in  |    2 --
 tools/lvmcmdline.c |    6 +++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 9bbf87b..cec74a9 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -114,8 +114,6 @@ LVMLIBS += -ldevmapper
 EXPORTED_HEADER = $(srcdir)/lvm2cmd.h
 EXPORTED_FN_PREFIX = lvm2
 
-DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
-
 CFLOW_LIST = lvmcmdlib.c lvm2cmd.c
 CFLOW_LIST_TARGET = liblvm2cmd.cflow
 CFLOW_TARGET = lvm
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 78974df..29fffb3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1925,12 +1925,12 @@ int lvm2_main(int argc, char **argv)
 		return -1;
 
 	if (is_static() && strcmp(base, "lvm.static") &&
-	    path_exists(LVM_SHARED_PATH) &&
+	    path_exists(LVM_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {
 		if (setenv("LVM_DID_EXEC", base, 1))
 			log_sys_error("setenv", "LVM_DID_EXEC");
-		if (execvp(LVM_SHARED_PATH, argv) == -1)
-			log_sys_error("execvp", "LVM_SHARED_PATH");
+		if (execvp(LVM_PATH, argv) == -1)
+			log_sys_error("execvp", LVM_PATH);
 		if (unsetenv("LVM_DID_EXEC"))
 			log_sys_error("unsetenv", "LVM_DID_EXEC");
 	}


