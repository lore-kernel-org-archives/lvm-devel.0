From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 21:51:58 +0000 (UTC)
Subject: master - libdm: replace assign with increment
Message-ID: <20151109215158.CC13861602@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb59847a0fe766ccddf5c3a57e2a0033077d62a2
Commit:        fb59847a0fe766ccddf5c3a57e2a0033077d62a2
Parent:        7ec61cd5b9d4fcafa5313602f0a0696fa4690f6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 22:48:13 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 22:51:48 2015 +0100

libdm: replace assign with increment

Coverity didn't liked assign with && expression, so use trick.
It does not complain against this prefix incremenent operation.
---
 libdm/libdm-report.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 23d0955..b9906d8 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -2219,8 +2219,7 @@ static const char *_tok_value_number(const char *s,
 	int is_float = 0;
 
 	*begin = s;
-	/* coverity[assign_where_compare_meant] */
-	while ((!is_float && (*s == '.') && ((is_float = 1))) || isdigit(*s))
+	while ((!is_float && (*s == '.') && ++is_float) || isdigit(*s))
 		s++;
 	*end = s;
 


