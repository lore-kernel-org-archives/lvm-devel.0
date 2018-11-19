From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 12:09:38 -0500
Subject: master - tests: missing copyright
Message-ID: <201811191709.wAJH9cH0030135@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb15373ad705a360c4a32d4ca9e97af949fec17a
Commit:        cb15373ad705a360c4a32d4ca9e97af949fec17a
Parent:        b968c73d2171b10f457babb2a5c428ffdc5ed21c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 17:16:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 17:58:09 2018 +0100

tests: missing copyright

---
 test/lib/dmsecuretest.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/test/lib/dmsecuretest.c b/test/lib/dmsecuretest.c
index 2ab7f81..d90546c 100644
--- a/test/lib/dmsecuretest.c
+++ b/test/lib/dmsecuretest.c
@@ -1,6 +1,18 @@
 /*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ *
  * Test sample code to check for leftovers from secure table loading in
- * userspace memory
+ * userspace memory (initial sample provided by Milan Broz).
  *
  * Compile with:  gcc -O2 -g -o tst dmcrypt.c -ldevmapper
  *


