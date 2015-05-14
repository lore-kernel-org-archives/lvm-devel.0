From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 09:28:17 +0000 (UTC)
Subject: master - spec: package old sysv initscript for lvmpolld
Message-ID: <20150514092817.94BBA610DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3a19fbe134086d46b29f9299074cc2a6c639fd7
Commit:        f3a19fbe134086d46b29f9299074cc2a6c639fd7
Parent:        64b40c5554599c48138820eca414c79ca3468a68
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 11:27:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 11:27:52 2015 +0200

spec: package old sysv initscript for lvmpolld

---
 spec/packages.inc |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 0aaae1d..f315524 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -187,6 +187,9 @@ fi
  %if %{have_service lvmetad}
   %{_sysconfdir}/rc.d/init.d/lvm2-lvmetad
  %endif
+ %if %{have_service lvmpolld}
+  %{_sysconfdir}/rc.d/init.d/lvm2-lvmpolld
+ %endif
 %endif
 
 ##############################################################################


