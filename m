From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:54 +0000 (UTC)
Subject: master - liblvm/python API: Additions & fixes
Message-ID: <20131119205654.4485560F74@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c8abb29df2e8cc22c43f67117486e4e717110dd
Commit:        7c8abb29df2e8cc22c43f67117486e4e717110dd
Parent:        5588a56391dd3ef61d284ea64bcb6da591a3136c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 19 14:54:18 2013 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:54:18 2013 -0600

liblvm/python API: Additions & fixes

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bd18c6f..e47f0e5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.105 -
 =====================================
+  liblvm/python API Add ability to validate VG/LV names.
+  liblvm/python API Add ability to create PV with arguments.
+  liblvm/python API Fail VG reduce when insufficient metadata copies
   Fix install of conf subdir when not building in srcdir.
   Add reporting of thin_id device id for thin volumes.
   Fix reporting of empty numerical values.


