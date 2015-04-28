From: okozina <okozina@fedoraproject.org>
Date: Tue, 28 Apr 2015 21:35:21 +0000 (UTC)
Subject: master - update copyright info in various files
Message-ID: <20150428213521.0BA51601FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a1474b98f90de0ed272935debc6773f08cdfbace
Commit:        a1474b98f90de0ed272935debc6773f08cdfbace
Parent:        90cbc5576fa8511c7045700fa7de0bc3b01e2225
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Apr 16 17:31:07 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Apr 28 22:45:19 2015 +0200

update copyright info in various files

basically transfer former date ranges from files where
the code originated from (pvmove.c and lvconvert.c)
---
 tools/lvconvert_poll.c |    2 +-
 tools/pvmove_poll.c    |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert_poll.c b/tools/lvconvert_poll.c
index 012911e..4745d06 100644
--- a/tools/lvconvert_poll.c
+++ b/tools/lvconvert_poll.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 0e9d639..cd32476 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *


