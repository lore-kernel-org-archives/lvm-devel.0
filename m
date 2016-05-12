From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 12 May 2016 00:15:06 +0000 (UTC)
Subject: master - libdm: Show lib vsn even if driver vsn unavailable.
Message-ID: <20160512001506.8357C61B56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6cafdad3608f58bc0cea6a73b16d9728fb92181
Commit:        e6cafdad3608f58bc0cea6a73b16d9728fb92181
Parent:        b5314c2a6ae5fe4f802e82a4f31cf2fad398ded9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 12 01:14:25 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 12 01:14:25 2016 +0100

libdm: Show lib vsn even if driver vsn unavailable.

---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f6392ef..a1d935e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.125 - 
 ==================================
+  Show library version in message even if dm driver version is unavailable.
 
 Version 1.02.124 - 30th April 2016
 ==================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 0c798f5..390daa1 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -570,9 +570,9 @@ int dm_check_version(void)
 
 	compat = "(compat)";
 
+      bad:
 	dm_get_library_version(libversion, sizeof(libversion));
 
-      bad:
 	log_error("Incompatible libdevmapper %s%s and kernel driver %s.",
 		  *libversion ? libversion : "(unknown version)", compat,
 		  *dmversion ? dmversion : "(unknown version)");


