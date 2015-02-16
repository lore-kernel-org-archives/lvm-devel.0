From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 16 Feb 2015 17:15:49 +0000 (UTC)
Subject: master - spec: Include lvmsystemid.7 in RPMs.
Message-ID: <20150216171549.7D57860F2B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ee82b545b5a1a1ca6cc7ae9d224ef981d59432f
Commit:        1ee82b545b5a1a1ca6cc7ae9d224ef981d59432f
Parent:        78d7466713a71c37fd241b5b2a9419c9914a7690
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Feb 16 17:14:23 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Mon Feb 16 17:15:03 2015 +0100

spec: Include lvmsystemid.7 in RPMs.

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index d368838..9fb3060 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -88,6 +88,7 @@ fi
 %if %{have_with thin}
   %{_mandir}/man7/lvmthin.7.gz
 %endif
+%{_mandir}/man7/lvmsystemid.7.gz
 %{_mandir}/man5/lvm.conf.5.gz
 %{_mandir}/man8/fsadm.8.gz
 %{_mandir}/man8/lvchange.8.gz


