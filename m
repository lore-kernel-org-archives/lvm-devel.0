From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 22:43:49 +0000 (UTC)
Subject: master - lvm2app: call fin_locking in lvm_quit
Message-ID: <20150502224349.6B66560CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74a81a4577ac3934952b3c731f699ef9a789592e
Commit:        74a81a4577ac3934952b3c731f699ef9a789592e
Parent:        bc52f07a8fe0d7a9aa4c0b2fd63109cbd06288b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 2 21:13:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 00:43:13 2015 +0200

lvm2app: call fin_locking in lvm_quit

lvm_quit() function should also close locking.
Fixes unclosed socket connecting clvmd.
---
 WHATS_NEW         |    1 +
 liblvm/lvm_base.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a21d2b2..5956b74 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  lvm2app closes locking on lvm_quit().
   Configure detects /run or /var/run.
   Add missing newline in clvmd --help output.
 
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 31fc0bb..c1954d1 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -96,6 +96,7 @@ lvm_t lvm_init(const char *system_dir)
 void lvm_quit(lvm_t libh)
 {
 	struct saved_env e = store_user_env((struct cmd_context *)libh);
+	fin_locking();
 	destroy_toolcontext((struct cmd_context *)libh);
 	udev_fin_library_context();
 	restore_user_env(&e);


