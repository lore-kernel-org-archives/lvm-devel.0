From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:58 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: improve previous patch
Message-ID: <20130604192558.039B66115D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=986a50e4a1c017cc655bbcce45ffa4444386678b
Commit:        986a50e4a1c017cc655bbcce45ffa4444386678b
Parent:        2d3700ba42e156aa8b6e2819736cab6866ea56ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 29 13:50:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:44:14 2013 +0200

cleanup: improve previous patch

Make the test earlier, before any dereference of 'argv' pointer.
---
 tools/lvmcmdline.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 60aa4d9..c03e9ef 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1487,6 +1487,9 @@ int lvm2_main(int argc, char **argv)
 	int ret, alias = 0;
 	struct cmd_context *cmd;
 
+	if (!argv)
+		return -1;
+
 	base = last_path_component(argv[0]);
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
 	    strcmp(base, "initrd-lvm"))
@@ -1499,7 +1502,7 @@ int lvm2_main(int argc, char **argv)
 		return -1;
 
 	if (is_static() && strcmp(base, "lvm.static") &&
-	    path_exists(LVM_SHARED_PATH) && argv &&
+	    path_exists(LVM_SHARED_PATH) &&
 	    !getenv("LVM_DID_EXEC")) {
 		if (setenv("LVM_DID_EXEC", base, 1))
 			log_sys_error("setenv", "LVM_DID_EXEC");


