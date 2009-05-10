From: Milan Broz <mbroz@redhat.com>
Date: Sun, 10 May 2009 20:06:10 +0200
Subject: [PATCH] Do not use generic install if running install_device-mapper.
In-Reply-To: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
References: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
Message-ID: <1241978772-6394-3-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It propagates into subdirs which includes DSOs which requires
lvm2 build (only install_device-mapper should propagate there).

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/dmeventd/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 2878cf2..1e659e0 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -63,7 +63,7 @@ endif
 
 install: $(INSTALL_TYPE) install_include install_dmeventd
 
-install_device-mapper: install
+install_device-mapper: $(INSTALL_TYPE) install_include install_dmeventd
 
 install_include:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.h \
-- 
1.6.2.4


