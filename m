From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  1 Apr 2014 09:19:53 +0000 (UTC)
Subject: master - man: add a note about --profile when using dumpconfig --mergedconfig
Message-ID: <20140401091953.D06BD60564@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13009adbf266b5e72eeb882286b43948b15cd49b
Commit:        13009adbf266b5e72eeb882286b43948b15cd49b
Parent:        68bb639a08330c7f06558e51ecab48d6a4ca2854
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 1 11:19:38 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 1 11:19:38 2014 +0200

man: add a note about --profile when using dumpconfig --mergedconfig

---
 man/lvm-dumpconfig.8.in |   10 ++++++----
 man/lvm.conf.5.in       |    2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
index 7448992..e9fe84e 100644
--- a/man/lvm-dumpconfig.8.in
+++ b/man/lvm-dumpconfig.8.in
@@ -80,10 +80,12 @@ complete and they are not meant to be used in production.
 .TP
 .B \-\-mergedconfig
 When the dumpconfig command is run with the \fB\-\-config\fP option
-(a common option that is recognized by all LVM tools, see also
-\fBlvm\fP(8)), merge this configuration with current configuration
-used (see \fB\-\-type current\fP above). Otherwise, only the
-configuration specified within \fB\-\-config\fP option is dumped.
+and/or \fB\-\-profile\fP option (common options that are recognized
+by all LVM tools, see also \fBlvm\fP(8)), merge the \fB\-\-config\fP
+and/or \fB\-\-profile\fP config with current configuration used
+(see \fB\-\-type current\fP above). Otherwise, only the configuration
+specified within \fB\-\-config\fP or \fB\-\-profile\fP option is dumped
+(see also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP).
 
 .TP
 .B \-\-validate
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 099c5a7..1bed3d9 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -67,7 +67,7 @@ exactly the same format as used in any LVM configuration file.
 .LP
 When several configuration methods are used at the same time
 and when LVM looks for the value of a particular setting, it traverses
-this cascade from left to right:
+this \fBconfig cascade\fP from left to right:
 \fBdirect config override on command line\fP -> \fBprofile config\fP -> \fBtag config\fP -> \fBlvm.conf\fP.
 No part of this cascade is compulsory. If there's no setting value found at
 the end of the cascade, a default value is used for that setting.


