From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 15:45:01 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210507154501.734CE385801A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64719861ec094607162cd4faa4a0b2f1d8a3421c
Commit:        64719861ec094607162cd4faa4a0b2f1d8a3421c
Parent:        00f603de2c507ee12195487fa007510ee3ff9770
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 7 17:44:43 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 7 17:44:43 2021 +0200

make: generate

---
 man/lvconvert.8_pregen | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 84b4ac75e..d733ab64f 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -551,7 +551,7 @@ Attach a writecache to an LV, converts the LV to type writecache.
 .RE
 .P
 .RS 4
-LV1 types: linear striped raid
+LV1 types: linear striped thinpool raid
 .RE
 .P
 \(em
@@ -605,7 +605,7 @@ Add a writecache to an LV, using a specified cache device.
 .RE
 .P
 .RS 4
-LV1 types: linear striped raid
+LV1 types: linear striped thinpool raid
 .RE
 .P
 \(em


