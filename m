From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:23 +0000 (UTC)
Subject: master - test: Run the testcases chdir'd into --testdir.
Message-ID: <20150205134123.4EE7660F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bc76bcdabe76876c59f9fec61292240993974bc
Commit:        2bc76bcdabe76876c59f9fec61292240993974bc
Parent:        efb3e7ca007f57c7627ef47e084d2f03cdc906f3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:23:14 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Run the testcases chdir'd into --testdir.

---
 test/lib/runner.cpp |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 7f1f495..bfcea91 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -270,6 +270,7 @@ struct TestCase {
 			exit(201);
 		} else if (pid == 0) {
 			io.close();
+			chdir( options.testdir.c_str() );
 			setenv("LVM_TEST_FLAVOUR", flavour.c_str(), 1);
 			child.exec();
 		} else {


