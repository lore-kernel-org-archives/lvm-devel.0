From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  7 Jun 2022 15:15:57 +0000 (GMT)
Subject: main - tests: skip running tests for non root user
Message-ID: <20220607151557.80B6738133EC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bea95764e7322f491c58fae2ec456ab7d60af95
Commit:        2bea95764e7322f491c58fae2ec456ab7d60af95
Parent:        4a498512077b4fe5cf6b806a91228bd23e513123
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 30 18:41:16 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 7 17:14:09 2022 +0200

tests: skip running tests for non root user

Testing needs 'root' privileges.
Only 'make run-unit-test' can work without them.
---
 test/lib/runner.cpp | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index d00aa457c..d522228a0 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -29,6 +29,12 @@
 
 int main(int argc, const char **argv)
 {
+
+    if (getuid() != 0) {
+        std::cout << "Skipping tests, root is required, current UID: " << getuid() << "\n";
+        return 0;
+    }
+
     try {
         return brick::shelltest::run( argc, argv, "LVM_TEST_FLAVOUR" );
     } catch (std::exception const& e) {

