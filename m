From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Jul 2013 12:03:59 +0000 (UTC)
Subject: master - libdm: add DM_ARRAY_SIZE
Message-ID: <20130708120359.2CEE86034E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b4f888bc5be23563167eb056582e7567b832f0b
Commit:        1b4f888bc5be23563167eb056582e7567b832f0b
Parent:        7c6526aae277c049aa4a6e41b7c2b30d366c9852
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 20:35:43 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 8 14:00:17 2013 +0200

libdm: add DM_ARRAY_SIZE

Add macro for reading detecting size of array.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4819a0b..2fc454b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Add DM_ARRAY_SIZE public macro.
   Move syslog code out of signal handle in dmeventd.
   Add DM_TO_STRING public macro.
   Always return success on dmeventd -V command call.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0434506..66396ce 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -38,6 +38,8 @@
 #define DM_TO_STRING_EXP(A) #A
 #define DM_TO_STRING(A) DM_TO_STRING_EXP(A)
 
+#define DM_ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
+
 #ifdef __cplusplus
 extern "C" {
 #endif


