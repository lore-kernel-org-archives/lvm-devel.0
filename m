From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:32 +0000 (UTC)
Subject: master - libdm: fail if buffer for version is to short
Message-ID: <20140408090232.4A64060CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=583fbdba84afae3a045915603c6c057c76fcf485
Commit:        583fbdba84afae3a045915603c6c057c76fcf485
Parent:        f0003d3be5b002aa27de978ad95fb2b310ca6529
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:43:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:12 2014 +0200

libdm: fail if buffer for version is to short

Return fail error code, if supplied buffer is too small.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6545127..49a7812 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  When buffer for dm_get_library_version() is too small, return error code.
   Always reinitialize _name_mangling_mode in dm_lib_init().
   Add tracking flag about implicitly added devices into dm_tree.
   Stop timeout thread immediately when the last worker thread is finished.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 9d8836c..93f3dd1 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -203,8 +203,7 @@ static void _build_dev_path(char *buffer, size_t len, const char *dev_name)
 
 int dm_get_library_version(char *version, size_t size)
 {
-	strncpy(version, DM_LIB_VERSION, size);
-	return 1;
+	return dm_strncpy(version, DM_LIB_VERSION, size);
 }
 
 void inc_suspended(void)


