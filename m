From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Oct 2012 13:17:27 +0000 (UTC)
Subject: master - Makefiles: fix distclean dir dependency
Message-ID: <20121015131727.BBF1A2349@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=895ee616425215136ec346d4637d2887add27913
Commit:        895ee616425215136ec346d4637d2887add27913
Parent:        d365bfe7e96b23297d3aac3485f98998bb220613
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 15 14:15:59 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 15 14:15:59 2012 +0100

Makefiles: fix distclean dir dependency

test distclean uses tools so must distclean tools after test
---
 Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index bbfcf2c..4d39577 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -44,6 +44,7 @@ ifeq ($(MAKECMDGOALS),distclean)
     libdaemon lib tools daemons libdm \
     udev po liblvm python \
     unit-tests/datastruct unit-tests/mm unit-tests/regex
+tools.distclean: test.distclean
 endif
 DISTCLEAN_DIRS += lcov_reports*
 DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl


