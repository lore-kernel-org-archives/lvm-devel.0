From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:06 +0000 (UTC)
Subject: master - spec: We do want thin support on RHEL 6.
Message-ID: <20140228102606.12E6960F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc6ed8fa66df4fba65a64b7111e26f5eb6b20162
Commit:        cc6ed8fa66df4fba65a64b7111e26f5eb6b20162
Parent:        4d081f072fe5b6f96112196fbb52a9b5cda21c55
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Dec 17 15:23:08 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

spec: We do want thin support on RHEL 6.

---
 spec/source.inc |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 6a5b509..4b93be3 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -33,6 +33,9 @@
 
 %global req_udev udev >= 158-1
 %global req_cluster openais >= 1.1.1-1, cman >= 3.0.6-1, corosync >= 1.2.0-1
+%endif
+
+%if %{fedora} == 16
 %with thin none
 %with thin_check
 %with thin_repair
@@ -55,6 +58,7 @@
 
 %if %{rhel} == 6
 %define req_udev udev >= 147-2
+%global req_dm_persistent device-mapper-persistent-data >= 0.1.4
 %endif
 
 ##############################################################


