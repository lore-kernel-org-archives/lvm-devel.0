From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jun 2015 11:43:57 +0000 (UTC)
Subject: master - tests: newer version needed for ext-orig
Message-ID: <20150623114357.52DFC60666@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ee3ccd826e609fa62a57205f0e8480686f906af
Commit:        7ee3ccd826e609fa62a57205f0e8480686f906af
Parent:        9c86d33e68ceb7a5a5e6754f4551545d915e403d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 23 11:56:42 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 23 11:56:42 2015 +0200

tests: newer version needed for ext-orig

---
 test/shell/lvcreate-thin-external-size.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index 73e36ea..d8e98f9 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -23,7 +23,9 @@ which cmp || skip
 #
 # Main
 #
-aux have_thin 1 3 0 || skip
+
+# Test needs thin-pool target with unaligned ext-orig size support
+aux have_thin 1 13 0 || skip
 
 aux prepare_pvs 2 640
 


