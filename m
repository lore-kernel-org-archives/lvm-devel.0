From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:34 +0000 (UTC)
Subject: master - makefiles: src dirs have depth 5
Message-ID: <20151013140434.D5F146017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93229184066a9b7726e3b572bca3f612ed2815fb
Commit:        93229184066a9b7726e3b572bca3f612ed2815fb
Parent:        83f00e91567d387caf02da9cd3791c3fef85c80d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 12 00:10:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:20 2015 +0200

makefiles: src dirs have depth 5

For tags generation scan depth 5.
---
 Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 68fbc79..e4d9937 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -234,7 +234,7 @@ ifneq ($(shell which ctags),)
 .PHONY: tags
 tags:
 	test -z "$(shell find $(top_srcdir) -type f -name '*.[ch]' -newer tags 2>/dev/null | head -1)" || $(RM) tags
-	test -f tags || find $(top_srcdir) -maxdepth 4 -type f -name '*.[ch]' -exec ctags -a '{}' +
+	test -f tags || find $(top_srcdir) -maxdepth 5 -type f -name '*.[ch]' -exec ctags -a '{}' +
 
 CLEAN_TARGETS += tags
 endif


