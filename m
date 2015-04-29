From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 29 Apr 2015 14:35:53 +0000 (UTC)
Subject: master - cleanup: lvmconfig man page typo
Message-ID: <20150429143553.3E99961040@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79ec8eb93ca9620d69cdf8ca294f76a53e652cfe
Commit:        79ec8eb93ca9620d69cdf8ca294f76a53e652cfe
Parent:        8b6b90b0730658c12169a0a8fffcf043be6c7eb6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 29 16:35:49 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 29 16:35:49 2015 +0200

cleanup: lvmconfig man page typo

---
 man/lvmconfig.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
index b855a6e..ff7c63b 100644
--- a/man/lvmconfig.8.in
+++ b/man/lvmconfig.8.in
@@ -151,7 +151,7 @@ info about \fBconfig cascade\fP.
 
 .TP
 .B \-\-showunsupported
-Include unsupported configuration settings to the output. These settings
+Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only or their support
 is not yet complete and they are not meant to be used in production. The
 \fBcurrent\fP and \fBdiff\fP types include unsupported settings in their


