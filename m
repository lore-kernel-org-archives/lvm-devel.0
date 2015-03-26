From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Mar 2015 15:12:47 +0000 (UTC)
Subject: master - tests: skip system_id test in cluster
Message-ID: <20150326151247.7D5F361079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22d43ee14a1a9700b76960da2c983ff55cc3630c
Commit:        22d43ee14a1a9700b76960da2c983ff55cc3630c
Parent:        147b0a17005f632647b31394dda402483322ccad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 26 16:10:48 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 26 16:10:48 2015 +0100

tests: skip system_id test in cluster

Let's see what we can do in cluster for system_id,
until resolved skip test for check_cluster.
---
 test/shell/system_id.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index d866675..ad8871a 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2008-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -13,6 +13,9 @@ test_description='Test system_id'
 
 . lib/inittest
 
+# Should 'system_id' be usable in cluster ??
+test -e LOCAL_CLVMD && skip
+
 aux prepare_devs 1
 
 # create vg with system_id using each source


