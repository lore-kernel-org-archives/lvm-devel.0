From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:39 +0000 (UTC)
Subject: master - cleanup: do not pass uninitialized space to selinux.
Message-ID: <20131115113939.348536135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cb9041764005c3a8f59b0b5ede3808b660d001a
Commit:        3cb9041764005c3a8f59b0b5ede3808b660d001a
Parent:        eb4b03768f3ae751518b77b69882539e0c864a90
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 24 14:47:32 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:38:37 2013 +0100

cleanup: do not pass uninitialized space to selinux.

Just like with dm_prepare_selinux_context rather initialize to NULL.
---
 libdm/libdm-common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index febcd0e..5ec5769 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -899,7 +899,7 @@ int dm_prepare_selinux_context(const char *path, mode_t mode)
 int dm_set_selinux_context(const char *path, mode_t mode)
 {
 #ifdef HAVE_SELINUX
-	security_context_t scontext;
+	security_context_t scontext = NULL;
 
 	if (is_selinux_enabled() <= 0)
 		return 1;


