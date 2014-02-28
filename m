From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:32 +0000 (UTC)
Subject: master - NIX: Add %with thin_repair to the specfile.
Message-ID: <20140228102532.7F8F160F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf67c0b393ca08f909180994f1e03690c3fbdfe1
Commit:        bf67c0b393ca08f909180994f1e03690c3fbdfe1
Parent:        adf262e0793c29d9c51250bb276c0cc4387a93b5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Aug 30 18:24:25 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:50 2014 +0100

NIX: Add %with thin_repair to the specfile.

---
 spec/source.inc |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index f82ff7b..1cbd8bf 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -15,6 +15,7 @@
 # TODO %global req_dm_persistent device-mapper-persistent-data >= 0.1.4
 %with thin internal
 %with thin_check %{_sbindir}/thin_check
+%with thin_repair %{_sbindir}/thin_repair
 
 %global buildreq_udev systemd-devel
 %global req_udev udev >= 181-1
@@ -33,6 +34,7 @@
 %global req_cluster openais >= 1.1.1-1, cman >= 3.0.6-1, corosync >= 1.2.0-1
 %with thin
 %with thin_check
+%with thin_repair
 %endif
 
 ##############################################################


