From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Oct 2015 15:04:01 +0000 (UTC)
Subject: master - tests: using matching type
Message-ID: <20151027150401.E5F8060C54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e1e0e881368be6337599dcf7f627f785ebf415c
Commit:        6e1e0e881368be6337599dcf7f627f785ebf415c
Parent:        4159680a0ee7eceb4d5124c1e4e78b418b12f357
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 27 15:33:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 27 16:00:10 2015 +0100

tests: using matching type

Compare time_t.
---
 test/lib/brick-shelltest.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index ccb4fb4..cc7135f 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -82,7 +82,7 @@
 #include "configure.h"
 
 /*  Timeout for the whole test suite in hours */
-static const unsigned TEST_SUITE_TIMEOUT = 4;
+static const time_t TEST_SUITE_TIMEOUT = 4;
 
 #ifndef BRICK_SHELLTEST_H
 #define BRICK_SHELLTEST_H


