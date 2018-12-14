From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:43 -0500
Subject: master - makefiles: some leftovers from lvmetad
Message-ID: <201812141417.wBEEHhos010350@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73bef5e3ddc962e462b3068fd0b1c7cbccad5176
Commit:        73bef5e3ddc962e462b3068fd0b1c7cbccad5176
Parent:        4801919b01de26df9c1940a997a54c47ca5fee5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 17:34:20 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:14:48 2018 +0100

makefiles: some leftovers from lvmetad

---
 libdm/make.tmpl.in |    2 +-
 make.tmpl.in       |    4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index c88505f..cc1642a 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -533,7 +533,7 @@ endif
 
 ifeq ("@USE_TRACKING@","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
- help check check_local check_cluster check_lvmetad check_lvmpolld))
+ help check check_local check_cluster check_lvmpolld))
     ifdef SOURCES
        -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
     endif
diff --git a/make.tmpl.in b/make.tmpl.in
index e52827b..1a101fc 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -258,12 +258,10 @@ endif
   ifneq ("@BUILD_DMEVENTD@", "yes")
   ifneq ("@BUILD_LVMLOCKD@", "yes")
   ifneq ("@BUILD_LVMPOLLD@", "yes")
-  ifneq ("@BUILD_LVMETAD@", "yes")
     DEFS += -DDEBUG_MEM
   endif
   endif
   endif
-  endif
 endif
 
 # end of fPIC protection
@@ -583,7 +581,7 @@ endif
 
 ifeq ("$(USE_TRACKING)","yes")
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
- help check check_local check_cluster check_lvmetad check_lvmpolld))
+ help check check_local check_cluster check_lvmpolld))
     ifdef SOURCES
        -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
     endif


