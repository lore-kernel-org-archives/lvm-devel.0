From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 10 Feb 2017 22:37:22 +0000 (UTC)
Subject: master - test: lvresize-raid.sh missing conditional
Message-ID: <20170210223722.E87E160E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=caa2094e33188806137a8fe6d8c6ecce779ecc59
Commit:        caa2094e33188806137a8fe6d8c6ecce779ecc59
Parent:        c908a8b131d0ae12cf87a271b10dfeaf65d4e0a7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 10 21:19:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 10 21:22:38 2017 +0100

test: lvresize-raid.sh missing conditional

Test missed to check for raid0 present in the kernel.

Related: rhbz1366296
---
 test/shell/lvresize-raid.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index b4f6058..691946d 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012,2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -17,7 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 aux have_raid 1 3 0 || skip
 
 levels="5 6 10"
-aux have_raid4 && levels="0 0_meta 4 $levels"
+aux have_raid4 && levels="4 $levels"
+aux have_raid 1 7 0 && levels="0 0_meta $levels"
 
 aux prepare_pvs 6
 


