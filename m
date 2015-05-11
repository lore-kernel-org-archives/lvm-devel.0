From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 12:41:21 +0000 (UTC)
Subject: master - spec: writable instalation
Message-ID: <20150511124121.131A0603E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed8ea6cb2f0f915cc357c210d3112d3fed234854
Commit:        ed8ea6cb2f0f915cc357c210d3112d3fed234854
Parent:        725136b57eef7a61e506a445d43e6632882dc0bf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 13:51:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 14:36:31 2015 +0200

spec: writable instalation

rpmbuild needs writable binaries (for debug symbol extraction)
---
 spec/build.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 176fdb1..30c6402 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -24,6 +24,7 @@
   --enable-applib \
   --enable-cmdlib \
   --enable-dmeventd \
+  --enable-write_install \
   %{configure_flags}
 
 make %{?_smp_mflags}


