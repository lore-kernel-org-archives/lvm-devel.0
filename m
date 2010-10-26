From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 26 Oct 2010 14:59:21 +0200
Subject: [PATCH 0/5] Fix NULL dereference
Message-ID: <cover.1288097372.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated patchset for NULL pointer dereferences issues reported by clang.

Unlike the first version - this time less aggresive solution is used.
INTERNAL_ERRORs are reported in these moments (if they would ever happen),
and the execution path aborts when such conditions are met.
Previous version was rather ignoring these paths and could lead to 
unwanted execution of other code parts.


Zdenek Kabelac (5):
  Check type is not NULL before access
  Ensure seg is nonnull
  Ensure  first is not NULL before dereference
  Fix theoretical usage of NULL pointer dereference
  Check for NULL pointer

 lib/activate/dev_manager.c |    5 +++++
 lib/format1/format1.c      |    5 +++++
 libdm/libdm-report.c       |    6 ++++++
 libdm/regex/ttree.c        |    6 ++++++
 tools/reporter.c           |    4 ++++
 5 files changed, 26 insertions(+), 0 deletions(-)

-- 
1.7.3.2


