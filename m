From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 13:20:16 +0000 (UTC)
Subject: master - spec: udev rules don't live under %{_prefix} on fc16/rhel6
Message-ID: <20140228132016.66DB261002@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c69d37d1260aac04b8964ca92af489a2de0e9d77
Commit:        c69d37d1260aac04b8964ca92af489a2de0e9d77
Parent:        f3b9fe60242456f0e89a30e89b2f2849a78bb9e8
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 14:18:15 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 14:18:15 2014 +0100

spec: udev rules don't live under %{_prefix} on fc16/rhel6

---
 spec/source.inc |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 4b93be3..0a1c270 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -33,6 +33,9 @@
 
 %global req_udev udev >= 158-1
 %global req_cluster openais >= 1.1.1-1, cman >= 3.0.6-1, corosync >= 1.2.0-1
+
+%global _udevbasedir /lib/udev
+%global _udevdir %{_udevbasedir}/rules.d
 %endif
 
 %if %{fedora} == 16


