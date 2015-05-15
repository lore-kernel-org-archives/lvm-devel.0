From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 May 2015 19:31:52 +0000 (UTC)
Subject: master - spec: new man page
Message-ID: <20150515193153.0020C60EED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=190e91231c7822fd7b1a3dcf0e17dd2fdf162a57
Commit:        190e91231c7822fd7b1a3dcf0e17dd2fdf162a57
Parent:        463c86008ba9cbadedc42b022bd5e5247b774513
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 15 21:14:25 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 15 21:31:28 2015 +0200

spec: new man page

---
 spec/packages.inc |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index f315524..b9caa65 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -152,8 +152,9 @@ fi
   %{_udevdir}/69-dm-lvm-metad.rules
  %endif
 %endif
-%if %{have_service lvmetad}
+%if %{have_service lvmpolld}
   %{_mandir}/man8/lvmpolld.8.gz
+  %{_mandir}/man8/lvm-lvpoll.8.gz
 %endif
 %dir %{_sysconfdir}/lvm
 %ghost %{_sysconfdir}/lvm/cache/.cache


