From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 20:17:41 +0000 (UTC)
Subject: master - tests: capture and print thrown errors
Message-ID: <20150311201741.CAC7860242@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=243a135fe9091a3d306ee09b397779e503bb6adf
Commit:        243a135fe9091a3d306ee09b397779e503bb6adf
Parent:        bdf4e3e2f20dd186f3640e808930c152fc8d77e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 15:42:20 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 21:17:23 2015 +0100

tests: capture and print thrown errors

---
 test/lib/runner.cpp |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index a5e4615..d00aa45 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -29,6 +29,12 @@
 
 int main(int argc, const char **argv)
 {
-	return brick::shelltest::run( argc, argv, "LVM_TEST_FLAVOUR" );
+    try {
+        return brick::shelltest::run( argc, argv, "LVM_TEST_FLAVOUR" );
+    } catch (std::exception const& e) {
+        std::cout << "Exception: " << e.what() << "\n";
+    }
+
+    return 1;
 }
 


