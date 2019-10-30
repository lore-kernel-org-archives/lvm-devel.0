From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:55 -0400
Subject: master - man lvmvdo: Correct spellings
Message-ID: <201910301543.x9UFhtl5016608@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12c47e0c98a24de619af63a8756a458cf6c069b3
Commit:        12c47e0c98a24de619af63a8756a458cf6c069b3
Parent:        75628a5f4c10c35f37f0a0c68f44e705eb9d1eef
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 09:35:14 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

man lvmvdo: Correct spellings

---
 man/lvmvdo.7_main |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index d42c1bd..582f7a8 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -86,7 +86,7 @@ The primary methods for using VDO with lvm2:
 
 .SS 1. Create VDOPoolLV with VDOLV
 
-Create an VDOPoolLV that will holds VDO data togehther with
+Create an VDOPoolLV that will holds VDO data together with
 virtual size VDOLV, that user can use. When the virtual size
 is not specified, then such LV is created with maximum size that
 always fits into data volume even if there cannot happen any
@@ -117,8 +117,8 @@ operation.
 Convert an already created/existing LV into a volume that can hold
 VDO data and metadata (a volume reference by VDOPoolLV).
 User will be prompted to confirm such conversion as it is \fBIRREVERSIBLY
-DESTROYING\fP content of such volume, as it's being immediatelly
-formated by \fBvdoformat\fP(8) as VDO pool data volume. User can
+DESTROYING\fP content of such volume, as it's being immediately
+formatted by \fBvdoformat\fP(8) as VDO pool data volume. User can
 specify virtual size of associated VDOLV with this VDOPoolLV.
 When the virtual size is not specified, it will set to the maximum size
 that can keep 100% uncompressible data there.


