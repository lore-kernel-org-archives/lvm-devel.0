From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:24 +0000 (UTC)
Subject: master - makefiles: deps depends on header links
Message-ID: <20150907154524.01EA560A75@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ba431e79e4914dfaf3cc74aeb52b46757acc8df
Commit:        3ba431e79e4914dfaf3cc74aeb52b46757acc8df
Parent:        d62448cb456170bab17b2af24e11df964666e1c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 14:00:27 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:43:27 2015 +0200

makefiles: deps depends on header links

Put include/.symlinks_created as a prerequisite for dep calc.
Otherwise if these are not generated and user enters tests subdir and
runs 'make' he just gets endless loop of dep calculation.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 3fd3410..7124144 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -448,7 +448,7 @@ $(LIB_STATIC): $(OBJECTS)
 	$(RM) $@
 	$(AR) rs $@ $(OBJECTS)
 
-%.d: %.c
+%.d: %.c $(INC_LNS)
 	$(MKDIR_P) $(dir $@); \
 	set -e; \
 	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \


