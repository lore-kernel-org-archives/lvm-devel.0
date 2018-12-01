From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:07:54 -0500
Subject: master - makefiles: avoid clustering out
Message-ID: <201812010007.wB107s58031192@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1e5b8832b99d977fda326e914a5d6d834316f42
Commit:        a1e5b8832b99d977fda326e914a5d6d834316f42
Parent:        38c7ba315dd4aa2c87a777225b3f3ca333ebe350
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 21:59:08 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:05:53 2018 +0100

makefiles: avoid clustering out

When ctags package is not installed, avoid cluttering output
from failing 'which' command.
---
 Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index dd8a526..e64836f 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -179,7 +179,7 @@ endif
 include $(top_srcdir)/device_mapper/Makefile
 include $(top_srcdir)/base/Makefile
 
-ifneq ($(shell which ctags),)
+ifneq ($(shell which ctags 2>/dev/null),)
 .PHONY: tags
 tags:
 	test -z "$(shell find $(top_srcdir) -type f -name '*.[ch]' -newer tags 2>/dev/null | head -1)" || $(RM) tags


