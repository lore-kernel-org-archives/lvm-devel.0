From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 15 Apr 2010 11:40:02 +0200
Subject: [PATCH 0/3] Hotfix for make install
Message-ID: <cover.1271324076.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset fixes relative linkage of libraries between
usrlibdir and libdir.
Also fixes usage of DESTDIR for infodir and mandir.

Zdenek Kabelac (3):
  Hotfix: $(datarootdir) has already $(DESTDIR)
  Script to create proper relative path
  Use relative paths for creating links .so

 make.tmpl.in       |    7 ++++---
 scripts/relpath.sh |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 tools/Makefile.in  |    2 +-
 3 files changed, 54 insertions(+), 4 deletions(-)
 create mode 100755 scripts/relpath.sh


