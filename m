From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:36:34 +0000 (UTC)
Subject: master - tests: lvresize with zero arg
Message-ID: <20160225223634.6378F60F80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23a4801dbcc4d351db6c251685e08f3fec30cbdd
Commit:        23a4801dbcc4d351db6c251685e08f3fec30cbdd
Parent:        1a9f743eefbe8d86f6a23838789c21136f02cdcd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 21:58:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 25 23:30:26 2016 +0100

tests: lvresize with zero arg

---
 test/shell/lvresize-usage.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvresize-usage.sh b/test/shell/lvresize-usage.sh
index 13f4e1f..a136147 100644
--- a/test/shell/lvresize-usage.sh
+++ b/test/shell/lvresize-usage.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2007-2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -18,6 +18,8 @@ aux prepare_vg 2 80
 
 lvcreate -L 10M -n lv -i2 $vg
 lvresize -l +4 $vg/lv
+not lvextend -L+0 $vg/lv
+not lvextend -l+0 $vg/lv
 lvremove -ff $vg
 
 lvcreate -L 64M -n $lv -i2 $vg


