From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 26 Nov 2010 11:31:11 -0500
Subject: [PATCH 2/2] Update lvm2app version number from 2 to 3.
In-Reply-To: <1290789071-8458-1-git-send-email-wysochanski@pobox.com>
References: <1290789071-8458-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290789071-8458-3-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Significant changes from version 2 to version 3 include:
- Add lvm_*_get_property: query any lvm object property (report field name)
- Add lvm_lv_list_lvsegs: obtain list of lvseg_t from lv_t.
- Add lvm_pv_list_pvsegs: obtain list of pvseg_t from pv_t.
- Add lvm_vgname_from_{pvid|device}: lookup a vgname from pvid or device
- Add lvm_{lv|pv}_from_{uuid|name}: lookup a pv or lv handle from uuid or name
- Fix: Allow lvm2app headers in C++ code
- Fix: Use include <> not "" in lvm2app.h
- Fix: Generate lvm2app symbols from header file.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 VERSION |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/VERSION b/VERSION
index 131feeb..36ea719 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.78(2)-cvs (2010-11-22)
+2.02.78(3)-cvs (2010-11-22)
-- 
1.7.2.2


