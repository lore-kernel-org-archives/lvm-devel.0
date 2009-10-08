From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu,  8 Oct 2009 14:16:19 +0200
Subject: [PATCH 01/11] debian: fix library search path in example.conf
In-Reply-To: <1255004189-7020-1-git-send-email-fdinitto@redhat.com>
References: <1255004189-7020-1-git-send-email-fdinitto@redhat.com>
Message-ID: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-ID: <20091008121619.rN9UtUFpS-eYMjLQEeaIKg3SWsaViUrEgiDD-8PjQhk@z>

this patch is debian specific and sets the library search path
to /lib/lvm2 to avoid cluttering /lib

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 1067665... 46c4dba... M	doc/example.conf
 doc/example.conf |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/doc/example.conf b/doc/example.conf
index 1067665..46c4dba 100644
--- a/doc/example.conf
+++ b/doc/example.conf
@@ -312,7 +312,7 @@ global {
     # Full pathnames can be given.
 
     # Search this directory first for shared libraries.
-    #   library_dir = "/lib"
+    #   library_dir = "/lib/lvm2"
 
     # The external locking library to load if locking_type is set to 2.
     #   locking_library = "liblvm2clusterlock.so"
-- 
1.5.4.3


