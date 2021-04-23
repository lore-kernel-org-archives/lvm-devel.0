From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:08 +0000 (GMT)
Subject: main - man: add missing _iorig suffix
Message-ID: <20210423210608.CADEA39450F9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a21028dea71464f93cd1c0836aee63ebfc3add10
Commit:        a21028dea71464f93cd1c0836aee63ebfc3add10
Parent:        579c9413212deb80c56628a11bd36ba9bace3a22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 12:37:18 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

man: add missing _iorig suffix

---
 man/lvm.8_main | 1 +
 1 file changed, 1 insertion(+)

diff --git a/man/lvm.8_main b/man/lvm.8_main
index 234442e64..6f86d0353 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -288,6 +288,7 @@ The LV name may also not contain any of the following strings:
 .RB ' _cdata ',
 .RB ' _cmeta ',
 .RB ' _corig ',
+.RB ' _iorig ',
 .RB ' _mimage ',
 .RB ' _mlog ',
 .RB ' _pmspare ',


