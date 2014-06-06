From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:25 +0000 (UTC)
Subject: dev-prajnoha-report-select - WHATS_NEW: For commit 9399b743 (prompt for VG cluster attr change)
Message-ID: <20140606120325.057F760FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f2aedb1903d1422b7093f6afbdd81d912c969b6
Commit:        1f2aedb1903d1422b7093f6afbdd81d912c969b6
Parent:        9399b74356f9d0c2fbbac824908b15d63c3935cd
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jun 5 22:29:16 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jun 5 22:30:50 2014 -0500

WHATS_NEW:  For commit 9399b743 (prompt for VG cluster attr change)

Minor change, but put a comment in WHATS_NEW anyway.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a2b8af7..65cac33 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Prompt when setting the VG cluster attr if the cluster is not setup.
   Allow --yes to skip prompt in vgextend (worked only with -f).
   Don't use name mangling for LVM - it never uses dm names with wrong char set.
   Remove default.profile and add {command,metadata}_profile_template.profile.


