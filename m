From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:01 +0000 (UTC)
Subject: master - spec: Explicitly disable thin when we don't want it.
Message-ID: <20140228102601.E091060F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=581eeaf9502a530351a6894ce6d8f6930711e0b2
Commit:        581eeaf9502a530351a6894ce6d8f6930711e0b2
Parent:        9c8db4e33ff9f2baab14d6cf6bdd09cd411f3c3b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Dec 16 16:23:34 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

spec: Explicitly disable thin when we don't want it.

---
 spec/source.inc |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 3da93ee..6a5b509 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -33,7 +33,7 @@
 
 %global req_udev udev >= 158-1
 %global req_cluster openais >= 1.1.1-1, cman >= 3.0.6-1, corosync >= 1.2.0-1
-%with thin
+%with thin none
 %with thin_check
 %with thin_repair
 %with thin_dump


