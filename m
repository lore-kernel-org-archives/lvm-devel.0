From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:53 +0000 (GMT)
Subject: main - cov: ignoring
Message-ID: <20210927165753.477123858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf0d558067926e716a370165e323187cf44c050a
Commit:        bf0d558067926e716a370165e323187cf44c050a
Parent:        dab4acb8f8b379f27bdd5cd2f9014385948cdcc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 22:08:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

cov: ignoring

---
 test/lib/not.c | 1 +
 tools/lvm.c    | 1 +
 2 files changed, 2 insertions(+)

diff --git a/test/lib/not.c b/test/lib/not.c
index 0245c3475..751c95b3d 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -82,6 +82,7 @@ int main(int args, char **argv) {
 		if (val)
 			(void) setenv("LVM_EXPECTED_EXIT_STATUS", val, 1);
 
+		/* coverity[os_cmd_sink] intentionally passing argv + 1 */
 		execvp(argv[1], &argv[1]);
 		/* should not be accessible */
 		return FAILURE;
diff --git a/tools/lvm.c b/tools/lvm.c
index cc67e924a..e80113e0d 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -19,6 +19,7 @@
 
 int main(int argc, char **argv)
 {
+	/* coverity[os_cmd_sink] intentionally passing argv */
 	return lvm2_main(argc, argv);
 }
 


