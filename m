From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 25 Feb 2016 16:51:39 +0000 (UTC)
Subject: master - dmstats: create dmstats symlink in test/lib
Message-ID: <20160225165139.A38EE60E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=985ed7822f2ac12724ef3bbd823644b0a74f400c
Commit:        985ed7822f2ac12724ef3bbd823644b0a74f400c
Parent:        42ae586fa72a30e0f22c0916e0551228d5eed5c3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Nov 26 12:37:22 2015 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Feb 25 16:40:58 2016 +0000

dmstats: create dmstats symlink in test/lib

Create a symbolic link in test/lib for 'dmstats', pointing to the
dmsetup binary in the tools/ build directory.
---
 test/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 98f6cc9..915a0b0 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -309,6 +309,7 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 		tools/dmsetup daemons/lvmetad/lvmetad \
 		daemons/lvmpolld/lvmpolld ; do \
 		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
+	$(LN_S) -f $(abs_top_builddir)/tools/dmsetup lib/dmstats
 	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
 	$(LN_S) -f $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone


