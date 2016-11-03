From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 11:43:15 +0000 (UTC)
Subject: master - libdm: report logging with errno as changed default
Message-ID: <20161103114315.5D9BA60DB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e50d434a353efac7d4947c7deeaf7cfd773ea6e1
Commit:        e50d434a353efac7d4947c7deeaf7cfd773ea6e1
Parent:        6af26273cb8c0ef310296ba0f4dd42751ab25b0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 3 12:07:27 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 12:43:09 2016 +0100

libdm: report logging with errno as changed default

When user changes logging with 'dm_log_with_errno_init()'
also report this as non default dm logging.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0b2cd3d..8cf0e05 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.136 - 
 ======================================
+  Report as non default dm logging also when logging with errno was changed.
   Use log_level() macro to consistently decode message log level in dmeventd.
   Still produce output when dmsetup dependency tree building finds dev missing.
   Check and report pthread_sigmask() failure in dmeventd.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 7756009..5deb555 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -174,7 +174,7 @@ void dm_log_init(dm_log_fn fn)
 
 int dm_log_is_non_default(void)
 {
-	return (dm_log == _default_log) ? 0 : 1;
+	return (dm_log == _default_log && dm_log_with_errno == _default_log_with_errno) ? 0 : 1;
 }
 
 void dm_log_with_errno_init(dm_log_with_errno_fn fn)


