From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 24 May 2018 10:03:21 -0400
Subject: master - man: another missed typo for thin plugin
Message-ID: <201805241403.w4OE3L14012089@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6f244599623ef547fe2c5f70e21abf4cce9a49d
Commit:        d6f244599623ef547fe2c5f70e21abf4cce9a49d
Parent:        7e85361c34ec539880fe8e764e4b49fc55f78a09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 24 15:01:52 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 24 16:02:31 2018 +0200

man: another missed typo for thin plugin

---
 man/dmeventd.8_main |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index 98b1b98..06f8f58 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -123,7 +123,7 @@ Command is executed with environmental variable
 in this environment will not try to interact with dmeventd.
 To see the fullness of a thin pool command may check these
 two environmental variables
-\fBDMEVENTD_THIN_POOL_DATA\fP and \fBDMEVENTD_THIN_POOL_DATA\fP.
+\fBDMEVENTD_THIN_POOL_DATA\fP and \fBDMEVENTD_THIN_POOL_METADATA\fP.
 Command can also read status with tools like \fBlvs\fP(8).
 .
 .SH ENVIRONMENT VARIABLES


