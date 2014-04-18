From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:08 +0000 (UTC)
Subject: master - makefiles: compile files on make
Message-ID: <20140418145508.979E160758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b748e3118988222560392fa795e093cd2ce0af4
Commit:        2b748e3118988222560392fa795e093cd2ce0af4
Parent:        1af05a7a166a470d1b9d86f88fdc64c2d984124b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 10:07:17 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:49 2014 +0200

makefiles: compile files on make

Make install should install already compiled/generated files.
---
 udev/Makefile.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/udev/Makefile.in b/udev/Makefile.in
index a2e2571..390069b 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -58,6 +58,8 @@ endif
 %_install: %.rules
 	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)
 
+all: $(DM_RULES) $(LVM_RULES)
+CLEAN_TARGETS = $(DM_RULES) $(LVM_RULES)
 install_device-mapper: $(DM_RULES:.rules=_install)
 install_lvm2: $(LVM_RULES:.rules=_install)
 


