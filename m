From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Nov 2022 15:43:03 +0000 (GMT)
Subject: main - man: dmsetup concise format consitency
Message-ID: <20221125154303.97228384F6DA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a02268e93800c0390650cbf12061b705acfc2196
Commit:        a02268e93800c0390650cbf12061b705acfc2196
Parent:        a5042375de3fd7146906614bffbcc960349c2b20
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 14:19:57 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 16:41:53 2022 +0100

man: dmsetup concise format consitency

Use <name> consistenly.
---
 man/dmsetup.8_main | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 7576b54bc..6260396e6 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -1020,7 +1020,7 @@ A concise representation of one of more devices.
 The representation of a device takes the form:
 .ad l
 .nh
-<name>,<uuid>,\:<minor>,<flags>,\:<table>\:[,<table>+]\:[;<dev_name>,<uuid>,\:<minor>,<flags>,<table>\:[,<table>+]]
+<name>,<uuid>,\:<minor>,<flags>,\:<table>\:[,<table>+]\:[;<name>,<uuid>,\:<minor>,<flags>,<table>\:[,<table>+]]
 .hy
 .ad b
 .TP

