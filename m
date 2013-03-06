From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:14:58 +0000 (UTC)
Subject: master - config: add vsn macro
Message-ID: <20130306111458.B0C19A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ea68f233c2196856fbc008e30b1eb17deb62701
Commit:        6ea68f233c2196856fbc008e30b1eb17deb62701
Parent:        6c81cd26ccb03f3452fedca651c876f2709ff0b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 5 16:39:36 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 08:52:55 2013 +0100

config: add vsn macro

The 'vsn' macro encodes the LVM2 version major, minor
and patchlevel number in a packed form using 16 bits.
---
 lib/config/config.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index 5c36f4d..079e9d1 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -18,6 +18,10 @@
 
 #include "lvm-types.h"
 
+/* 16 bits: 3 bits for major, 4 bits for minor, 9 bits for patchlevel */
+/* Max LVM version supported: 7.15.511. Just extend bits if ever needed. */
+#define vsn(major, minor, patchlevel) (major << 13 | minor << 9 | patchlevel)
+
 struct device;
 struct cmd_context;
 


