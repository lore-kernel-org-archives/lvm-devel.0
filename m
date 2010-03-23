From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:33 +0100
Subject: [PATCH 0/6] Makefile updates
Message-ID: <cover.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set fixes few minor Makefile errors mostly
around clean & distclean targets. Major topic is the update 
of cflow rules.

Zdenek Kabelac (6):
  Reuse clean target for distclean
  Query make.tmpl variable
  Fix cleanup of libdevmapper-event.a and dmeventd
  Fix run of cscope in $(builddir)
  Fix distclean error for subtargets
  Update cflow

 Makefile.in                                 |   25 ++++-------
 daemons/Makefile.in                         |    9 ++++-
 daemons/dmeventd/Makefile.in                |   27 ++++++++++---
 daemons/dmeventd/plugins/mirror/Makefile.in |   11 ++++-
 include/Makefile.in                         |    3 +-
 lib/Makefile.in                             |   21 ++++++----
 libdm/Makefile.in                           |    4 ++
 make.tmpl.in                                |   58 +++++++++++++++++++++++----
 tools/Makefile.in                           |   23 ++++-------
 9 files changed, 122 insertions(+), 59 deletions(-)


