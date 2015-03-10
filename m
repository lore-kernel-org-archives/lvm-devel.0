From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 10 Mar 2015 14:37:55 +0000 (UTC)
Subject: master - WHATS_NEW vgconvert -M fix
Message-ID: <20150310143755.44CDB60254@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5cc96a54e9563b8aa5445a049facbe30a59fb39
Commit:        f5cc96a54e9563b8aa5445a049facbe30a59fb39
Parent:        321e19d9cc868ae475ea1a0a4b026bf5b84ccd5a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 10 09:38:43 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 10 09:38:43 2015 -0500

WHATS_NEW vgconvert -M fix

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 680879d..b4fd415 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Disallow vgconvert from changing metadata format when lvmetad is used.
   Don't do a full read of VG when creating a new VG with an existing name.
   Reduce number of VG metadata parsing when looking for vgname on a PV.
   Avoid reparsing same metadata when reading same metadata from multiple PVs.


