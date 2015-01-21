From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 21 Jan 2015 12:24:13 +0000 (UTC)
Subject: master - libdevmapper: Improve incompatible version msg.
Message-ID: <20150121122413.67CD461007@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cfc9a4f640296679f2b860842cc8b25b82fd30f
Commit:        7cfc9a4f640296679f2b860842cc8b25b82fd30f
Parent:        338d98be97428bd9202391abe705e7fe10ec5ce8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 21 12:23:56 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 21 12:23:56 2015 +0000

libdevmapper: Improve incompatible version msg.

---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 98f98b6..0a59875 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.93 -
 ====================================
+  Report 'unknown version' when incompatible version numbers were not obtained.
   Report more info from thin pool status (out of data, metadata-ro, fail).
   Support error_if_no_space for thin pool target.
   Fix segfault while using selection with regex and unbuffered reporting.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 4c37a53..f8b4ed9 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -571,8 +571,9 @@ int dm_check_version(void)
 	dm_get_library_version(libversion, sizeof(libversion));
 
       bad:
-	log_error("Incompatible libdevmapper %s%s and kernel driver %s",
-		  libversion, compat, dmversion);
+	log_error("Incompatible libdevmapper %s%s and kernel driver %s.",
+		  *libversion ? libversion : "(unknown version)", compat,
+		  *dmversion ? dmversion : "(unknown version)");
 
 	_version_ok = 0;
 	return 0;


