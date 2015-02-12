From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 12 Feb 2015 12:28:55 +0000 (UTC)
Subject: master - test: Fix missing return in new test harness.
Message-ID: <20150212122855.7B4B36062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e9f3dba75af605934a130d9a0ae9517229b0661
Commit:        0e9f3dba75af605934a130d9a0ae9517229b0661
Parent:        cc755853c271e0cef07650344ee0dfd74ce6fae9
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Feb 12 13:26:38 2015 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Feb 12 13:28:26 2015 +0100

test: Fix missing return in new test harness.

---
 test/lib/runner.cpp |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 7c2bcb5..a5e4615 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -29,6 +29,6 @@
 
 int main(int argc, const char **argv)
 {
-	brick::shelltest::run( argc, argv, "LVM_TEST_FLAVOUR" );
+	return brick::shelltest::run( argc, argv, "LVM_TEST_FLAVOUR" );
 }
 


