From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Apr 2010 11:07:18 +0200
Subject: [PATCH 0/3] Fix bugs for invalid regex input
Message-ID: <cover.1272618315.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This small patchset fixes error messages shown to the user,
when he makes a mistake in regex input.

Zdenek Kabelac (3):
  Display errornous pattern to the user
  Release allocated pools in error path
  Fix internal error for errornous regex insert

 lib/cache/lvmcache.c       |    8 ++++----
 lib/commands/toolcontext.c |    9 +++++++--
 lib/filters/filter-regex.c |    4 ++--
 3 files changed, 13 insertions(+), 8 deletions(-)


