From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 29 Oct 2013 12:55:29 +0000 (UTC)
Subject: master - udev: no need to check DM_NOSCAN in lvmetad rules
Message-ID: <20131029125529.125B66105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=264b5c2b1252fae5918307326c2db07752b59001
Commit:        264b5c2b1252fae5918307326c2db07752b59001
Parent:        db05a0cf6fde3be23ea1123a76477576923af8cc
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 29 13:54:14 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 29 13:54:14 2013 +0100

udev: no need to check DM_NOSCAN in lvmetad rules

It's covered by general DM_UDEV_DISABLE_OTHER_RULES_FLAG.
---
 udev/69-dm-lvm-metad.rules.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 34441ab..949c897 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -17,7 +17,6 @@
 SUBSYSTEM!="block", GOTO="lvm_end"
 (LVM_EXEC_RULE)
 
-ENV{DM_NOSCAN}=="1", GOTO="lvm_end"
 ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="lvm_end"
 
 # If the PV label got lost, inform lvmetad immediately.


