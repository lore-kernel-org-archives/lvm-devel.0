From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:55 +0000 (GMT)
Subject: dev-next - man: show config options with comments
Message-ID: <20210331214955.BAA973858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5b0c72f40abc8caa199a0f484a9a0223f4a03dc
Commit:        d5b0c72f40abc8caa199a0f484a9a0223f4a03dc
Parent:        ff5776024f056aeff0f1dac9f028e55761e7c24b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 30 13:01:31 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:08:14 2021 +0200

man: show config options with comments

---
 man/lvmvdo.7_main | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 520a28ecf..55b9fa2a6 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -121,8 +121,8 @@ VDO allows to set a large variety of options. Lots of these settings
 can be specified in lvm.conf or profile settings. You can prepare
 a number of different profiles in the #DEFAULT_SYS_DIR#/profile directory
 and just specify the profile file name.
-Check the output of \fBlvmconfig --type full\fP for a detailed description
-of all individual VDO settings.
+Check the output of \fBlvmconfig --type default --withcomments\fP
+for a detailed description of all individual VDO settings.
 
 .I Example
 .nf


