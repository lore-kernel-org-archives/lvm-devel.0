From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  2 Jul 2013 19:26:48 +0000 (UTC)
Subject: master - liblvm/python-lvm New additions
Message-ID: <20130702192648.9A0A961156@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79106f73940762ccde7fa536f37f922ba4773b70
Commit:        79106f73940762ccde7fa536f37f922ba4773b70
Parent:        04efe869a440590d99a886cda74aaf259b8067d7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jul 1 17:23:06 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jul 2 14:24:34 2013 -0500

liblvm/python-lvm New additions

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b68360f..5d9d27a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.99 - 
 ===================================
+  liblvm/python API: Additions: PV create/removal/resize/listing
+  liblvm/python API: Additions: LV attr/origin/Thin pool/Thin LV creation
   Add vgs/lvs -o vg_profile/lv_profile to report profiles attached to VG/LV.
   Add default.profile configuration profile and install it on make install.
   Create a new 'conf' subdir for configuration files including profiles.


