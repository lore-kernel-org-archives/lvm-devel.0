From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Mar 2013 14:43:49 +0000 (UTC)
Subject: master - WHATS_NEW: vgextend and PV with 0 MDAs
Message-ID: <20130319144349.95F73A1045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=784867d5bd47fce992b6b6e964d9088a652fc0b9
Commit:        784867d5bd47fce992b6b6e964d9088a652fc0b9
Parent:        ea36d0501e0ede347f251f6cda20903ad13f3700
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 19 15:41:21 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 19 15:41:34 2013 +0100

WHATS_NEW: vgextend and PV with 0 MDAs

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 68a7d03..a35c09b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix vgextend to not allow a PV with 0 MDAs to be used while already in a VG.
   Move update_pool_params() from /tools to /lib for better reuse.
   Give precedence to EMC power2 devices with duplicate PVIDs.
   Add --validate option to lvm dumpconfig to validate current config on demand.


