From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 09:58:17 +0000 (UTC)
Subject: master - headers: use __linux__ instead of linux
Message-ID: <20131017095817.226E361313@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=efd1dc6bd3e38f9a98f67db28537c5655992c6f9
Commit:        efd1dc6bd3e38f9a98f67db28537c5655992c6f9
Parent:        3924a041ba3798c228749de1fc5491fd5411103b
Author:        mpatocka at redhat.com <mpatocka@redhat.com>
AuthorDate:    Thu Oct 17 11:14:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 11:54:44 2013 +0200

headers: use __linux__ instead of linux

This file may be included by other programs, so it should be compliant
with the C standard.

* use __linux__ instead of linux - __linux__ is always defined, linux is
  not defined when gcc runs in standard-compliant mode (with -std=c89 or
  -std=c99) because the C standard doesn't allow polluting namespace
  with arbitrary defines.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6287fb4..cf1cb18 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.83
 ==================================
+  Use __linux__ instead of linux define to make libdevmapper.h C compliant.
 
 Version 1.02.82 - 4th October 2013
 ==================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index aaf00b2..adfbb76 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -21,7 +21,7 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 
-#ifdef linux
+#ifdef __linux__
 #  include <linux/types.h>
 #endif
 


