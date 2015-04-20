From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 20 Apr 2015 17:22:01 +0000 (UTC)
Subject: master - tests: add extra keyword for timing control
Message-ID: <20150420172201.5077F60221@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85e833c172a0a0403c1de5e6f480a67629e51e36
Commit:        85e833c172a0a0403c1de5e6f480a67629e51e36
Parent:        2b4f10ac668f01e63528ccea71545c06120fa9aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 20 19:09:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 20 19:18:56 2015 +0200

tests: add extra keyword for timing control

Control logging of timer with
"## timing off"  and "## timing on"
---
 test/lib/brick-shelltest.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 54114db..af8051e 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -326,10 +326,12 @@ struct TimedBuffer {
                 data.push_back( incomplete );
                 if (incomplete.second[0] == '#') {
                     /* Disable timing between '## 0 STACKTRACE' & '## teardown' keywords */
-                    if (incomplete.second.find("# 0 STACKTRACE", 1) != std::string::npos) {
+                    if (incomplete.second.find("# 0 STACKTRACE", 1) != std::string::npos ||
+                        incomplete.second.find("# timing off", 1) != std::string::npos) {
                         stamp = false;
                         now = 0;
-                    } else if (incomplete.second.find("# teardown", 1) != std::string::npos) {
+                    } else if (incomplete.second.find("# teardown", 1) != std::string::npos ||
+                               incomplete.second.find("# timing on", 1) != std::string::npos) {
                         stamp = true;
                         now = time( 0 );
                     }


