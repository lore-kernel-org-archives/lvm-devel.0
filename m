From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  7 Oct 2010 16:06:32 +0200
Subject: [PATCH 2/9] Fix return value from break trap
In-Reply-To: <cover.1286460218.git.zkabelac@redhat.com>
References: <cover.1286460218.git.zkabelac@redhat.com>
Message-ID: <a931feb62093ef1b53f24e754e97b18d08c7c689.1286460218.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This bug is serious as upon certain conditions it is possible
to break (^C) fsadm before actually resizing filesystem, but the
ongoing lvresize will think resize was succesful and shrinks
partition with unresized filesystem on it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/fsadm.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index aa6b2d9..2c6a21b 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -130,7 +130,8 @@ cleanup() {
 	# and allow recursive call of fsadm
 	unset FSADM_RUNNING
 	test "$DO_LVRESIZE" -eq 2 && exec $LVM lvresize $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
-	exit ${1:-0}
+	# error exit status for break
+	exit ${1:-1}
 }
 
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
-- 
1.7.3.1


