From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 4 Mar 2013 18:34:34 -0500 (EST)
Subject: [PATCH] lvm testsuite: Use #!/bin/bash
Message-ID: <Pine.LNX.4.64.1303041834140.621@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm testsuite: Use #!/bin/bash

On some systems /bin/sh is a link for dash, not bash
This script doesn't work with dash, so use #!/bin/bash.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 test/lib/get.sh |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2.2.02.98/test/lib/get.sh
===================================================================
--- LVM2.2.02.98.orig/test/lib/get.sh	2013-01-30 20:16:06.000000000 +0100
+++ LVM2.2.02.98/test/lib/get.sh	2013-01-30 20:16:10.000000000 +0100
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 # Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,


