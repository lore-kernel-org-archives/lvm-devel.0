From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 16:27:33 -0400
Subject: master - man pvchange: mention one option is required
Message-ID: <201705032027.v43KRXQ5032239@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab1de07c9747074a5d3fa0a3f49a54310854a5a0
Commit:        ab1de07c9747074a5d3fa0a3f49a54310854a5a0
Parent:        27736676275fefa3367db2939ddfa0c8cce48c04
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 15:10:10 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 15:10:10 2017 -0500

man pvchange: mention one option is required

---
 man/pvchange.8_des |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/pvchange.8_des b/man/pvchange.8_des
index 802850f..e914e13 100644
--- a/man/pvchange.8_des
+++ b/man/pvchange.8_des
@@ -1 +1,4 @@
 pvchange changes PV attributes in the VG.
+
+For options listed in parentheses, any one is required, after which the
+others are optional.


