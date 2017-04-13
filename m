From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 13 Apr 2017 11:21:36 -0400
Subject: master - conf: Remove exec_prefix from confdir.
Message-ID: <201704131521.v3DFLa2q026632@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c6a6ce6cd5a80e78094aa6420e3cb53a478eef76
Commit:        c6a6ce6cd5a80e78094aa6420e3cb53a478eef76
Parent:        5ae7a016b8e5796d36cf491345b1cf8e43ec9ea5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 13 16:19:33 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 13 16:21:29 2017 +0100

conf: Remove exec_prefix from confdir.

Some distros now want to put /etc outside prefix/exec_prefix.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index c3e6c8c..a40eaaa 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -82,7 +82,7 @@ udev_prefix = @udev_prefix@
 sysconfdir = @sysconfdir@
 rootdir = $(DESTDIR)/
 bindir = $(DESTDIR)@bindir@
-confdir = $(DESTDIR)$(exec_prefix)@CONFDIR@/lvm
+confdir = $(DESTDIR)@CONFDIR@/lvm
 profiledir = $(confdir)/@DEFAULT_PROFILE_SUBDIR@
 includedir = $(DESTDIR)@includedir@
 libdir = $(DESTDIR)@libdir@


