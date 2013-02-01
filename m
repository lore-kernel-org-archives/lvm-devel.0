From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri,  1 Feb 2013 18:01:57 +0000 (UTC)
Subject: master - WHATS_NEW: Better description of previous change
Message-ID: <20130201180157.75FDE137D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38e7b37c897da9cfae8cb3b77ea585b7616d9813
Commit:        38e7b37c897da9cfae8cb3b77ea585b7616d9813
Parent:        801d4f96a8a2333361d7292d9c79ffdb5a96fac3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Feb 1 11:52:25 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Feb 1 11:52:25 2013 -0600

WHATS_NEW:  Better description of previous change

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8eea410..ba8d148 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.02.99 - 
 ===================================
-  Improve 'lvs' attribute reporting of RAID LVs and sub-LVs
+  Report partial and in-sync RAID attribute based on kernel status
   Fix blkdeactivate to handle nested mountpoints and mangled mount paths.
   Set locales with LC_ALL instead of lower priority LANG variable.
   Fix a crash-inducing race condition in lvmetad.


