From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:04 +0000 (UTC)
Subject: master - tests: update make targets
Message-ID: <20161111160004.7052A601A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a2250f9cea300598fff8dbfee8700ac7aa81f89
Commit:        4a2250f9cea300598fff8dbfee8700ac7aa81f89
Parent:        d8fc4d093ee125e3667046b892c14e4a920a8da0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 17 11:13:43 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:20 2016 +0100

tests: update make targets

Add  new targets:

make check_lvmpolld
make check_cluster_lvmpolld
make check_lvmetad_lvmpolld
make check_all_lvmpolld

So check_lvmetad runs only base lvmetad test - to much
logic of remaining targets.

Previous behavior is available via  check_all_lvmpolld.
---
 test/Makefile.in |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 94b3105..bc501d1 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -77,6 +77,9 @@ help:
 	@echo "  check_cluster		Run tests with cluster daemon."
 	@echo "  check_lvmetad		Run tests with lvmetad daemon."
 	@echo "  check_lvmpolld         Run tests with lvmpolld daemon."
+	@echo "  check_cluster_lvmpolld Run tests with clvmd and lvmpolld daemon."
+	@echo "  check_lvmetad_lvmpolld Run tests with lvmetad and lvmpolld daemon."
+	@echo "  check_all_lvmpolld     Run all tests with lvmpolld daemon."
 	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
 	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
 	@echo "  check_lvmlockd_test    Run tests with lvmlockd --test."
@@ -146,6 +149,21 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 check_lvmpolld: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir results \
+		--flavours ndev-lvmpolld --only $(T) --skip $(S)
+
+check_cluster_lvmpolld: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours ndev-cluster-lvmpolld --only $(T) --skip $(S)
+
+check_lvmetad_lvmpolld: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours ndev-lvmetad-lvmpolld --only $(T) --skip $(S)
+
+check_all_lvmpolld: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
 		--flavours ndev-lvmpolld,ndev-cluster-lvmpolld,ndev-lvmetad-lvmpolld --only $(T) --skip $(S)
 endif
 


