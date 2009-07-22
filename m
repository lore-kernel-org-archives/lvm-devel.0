From: Thomas Woerner <twoerner@redhat.com>
Date: Wed, 22 Jul 2009 17:38:11 +0200
Subject: [PATCH 0/5] liblvm2app version and install patchset
Message-ID: <1248277096-29947-1-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following patches will add the api version for liblvm2app, the install environment for liblvm2app and also a pkgconfig file.

Changes for the parsing of VERSIONS was neede for this.
LIB_STATIC remains from the liblvm/Makefile.in have been removed.

Thomas Woerner (5):
  Add liblvm2app api version as so minor version number for
    liblvm2app.so.<major>.<lvm2app api version>
  Use LIB_VERSION_APPLIB as liblvm so version.
  Remove LIB_STATIC remains from liblvm/Makefile.in.
  Add liblvm dynamic install target.
  Add lvm2app pkgconfig file

 VERSION              |    2 +-
 configure.in         |   10 +++++++---
 liblvm/Makefile.in   |   36 +++++++++++++++++++++++++++++++-----
 liblvm/lvm2app.pc.in |   11 +++++++++++
 make.tmpl.in         |    3 +++
 5 files changed, 53 insertions(+), 9 deletions(-)
 create mode 100644 liblvm/lvm2app.pc.in


