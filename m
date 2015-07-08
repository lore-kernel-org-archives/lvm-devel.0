From: Andy Grover <grover@fedoraproject.org>
Date: Wed,  8 Jul 2015 17:02:38 +0000 (UTC)
Subject: master - man: add lvmlocal.conf to config cascade
Message-ID: <20150708170238.B08C7612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d77546773bfe0dd2db98427d6b5b16fa4f19e47a
Commit:        d77546773bfe0dd2db98427d6b5b16fa4f19e47a
Parent:        de13abdfdf44c1119ee03c2514dd886191f3d9c3
Author:        Andy Grover <agrover@redhat.com>
AuthorDate:    Wed Jul 8 10:02:28 2015 -0700
Committer:     Andy Grover <agrover@redhat.com>
CommitterDate: Wed Jul 8 10:02:28 2015 -0700

man: add lvmlocal.conf to config cascade

see BZ 1241182, lvmlocal is searched before lvm.conf but after
lvm_<tag>.conf.
---
 man/lvm.conf.5.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 6ff8674..ae884be 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -87,7 +87,7 @@ When several configuration methods are used at the same time
 and when LVM looks for the value of a particular setting, it traverses
 this \fBconfig cascade\fP from left to right:
 
-\fBdirect config override on command line\fP -> \fBcommand profile config\fP -> \fBmetadata profile config\fP -> \fBtag config\fP -> \fBlvm.conf\fP
+\fBdirect config override on command line\fP -> \fBcommand profile config\fP -> \fBmetadata profile config\fP -> \fBtag config\fP -> \fBlvmlocal.conf\fB -> \fBlvm.conf\fP
 
 No part of this cascade is compulsory. If there's no setting value found at
 the end of the cascade, a default value is used for that setting.


