From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 3 Mar 2017 16:25:16 -0500
Subject: master - man: fix term in lvmraid(7)
Message-ID: <201703032125.v23LPGLm012932@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6dea1ed5ae47018d75532203660eca0decbda08e
Commit:        6dea1ed5ae47018d75532203660eca0decbda08e
Parent:        e4ef3d04ad3a2870f94557250006e4c93431b0bb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 3 22:24:13 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 3 22:24:53 2017 +0100

man: fix term in lvmraid(7)

Adjust commit af7c8e710663 to use "image/leg".

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 man/lvmraid.7.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index e0657b8..832242c 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -22,7 +22,7 @@ devices, and MD is used to place data on physical devices.
 LVM creates hidden LVs (dm devices) layered between the visible LV and
 physical devices.  LVs in that middle layers are called sub LVs.
 For LVM raid, a sub LV pair to store data and metadata (raid superblock
-and bitmap) is created per raid leg (see lvs command examples below).
+and bitmap) is created per raid image/leg (see lvs command examples below).
 
 .SH Create a RAID LV
 


