From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 15 Aug 2013 10:52:22 +0000 (UTC)
Subject: master - fix: ambiguity in log_sys_error call from previous commit
Message-ID: <20130815105223.028806006E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1dc4d3d81456d506b2c56fb2e8b12106cbd9e16
Commit:        f1dc4d3d81456d506b2c56fb2e8b12106cbd9e16
Parent:        0563bd0037610397c5838d0172fd1c913c62c187
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 15 12:40:47 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 15 12:50:58 2013 +0200

fix: ambiguity in log_sys_error call from previous commit

libdm-common.c:883:42: warning: pointer/integer type mismatch in conditional expression

define log_sys_error(x, y) log_err("%s%s%s failed: %s", y, *y ? ": " : "", x, strerror(errno))

So the "y" which was 'path ? : "SELinux context reset"' from
previous commit did not quite fit the other "? :" in the log_sys_macro.
---
 libdm/libdm-common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 4f398f1..9043352 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -880,7 +880,7 @@ int dm_prepare_selinux_context(const char *path, mode_t mode)
 		log_debug_activation("Resetting SELinux context to default value.");
 
 	if (setfscreatecon(scontext) < 0) {
-		log_sys_error("setfscreatecon", path ? : "SELinux context reset");
+		log_sys_error("setfscreatecon", (path ? : "SELinux context reset"));
 		freecon(scontext);
 		return 0;
 	}


