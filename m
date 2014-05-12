From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:48 +0000 (UTC)
Subject: master - conf: document new thin_check option
Message-ID: <20140512142548.A94116030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90c44f5371b85edb05d4c4ebbd9e0254971d13f4
Commit:        90c44f5371b85edb05d4c4ebbd9e0254971d13f4
Parent:        8b95c82fed667b4095b1358ac5697fd43cd61e11
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 12 14:12:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:40 2014 +0200

conf: document new thin_check option

---
 conf/example.conf.in |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index d5ddb1c..bc1758d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -693,8 +693,10 @@ global {
     # option "-q" is for quiet output.
     # With thin_check version 2.1 or newer you can add "--ignore-non-fatal-errors"
     # to let it pass through ignorable errors and fix them later.
+    # With thin_check version 3.2 or newer you should add
+    # "--clear-needs-check-flag".
     #
-    # thin_check_options = [ "-q" ]
+    # thin_check_options = [ "-q", "--clear-needs-check-flag" ]
 
     # Full path of the utility called to repair a thin metadata device
     # is in a state that allows it to be used.


