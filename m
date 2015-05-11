From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 12:41:25 +0000 (UTC)
Subject: master - spec: now generated
Message-ID: <20150511124125.53F90603E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b5b3ad14a83b1c5a876b11b27c825d473110d9f5
Commit:        b5b3ad14a83b1c5a876b11b27c825d473110d9f5
Parent:        7de615339571be4b0ee593b58d5e1c5abd661c4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 14:30:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 14:40:54 2015 +0200

spec: now generated

---
 spec/source.inc |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/spec/source.inc b/spec/source.inc
index 21fbf7d..36cb30f 100644
--- a/spec/source.inc
+++ b/spec/source.inc
@@ -72,12 +72,12 @@
 # Do not reset Release to 1 unless both lvm2 and device-mapper
 # versions are increased together.
 
-%define device_mapper_version 1.02.75
+%define device_mapper_version 1.02.97
 
 Summary: Userland logical volume management tools
 Name: lvm2
-Version: 2.02.96
-Release: 4%{?dist}
+Version: 2.02.120
+Release: 1%{?dist}
 License: GPLv2
 Group: System Environment/Base
 URL: http://sources.redhat.com/lvm2


