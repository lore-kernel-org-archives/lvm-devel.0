From: Tony Asleson <tasleson@redhat.com>
Date: Tue,  5 May 2015 16:34:14 -0500
Subject: [PATCH 0/5] V2 lvm2app & python bindings bug fixes
Message-ID: <1430861659-2755-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set should resolve the following issues:

* Handle signed properties better

I added another flag on the properties structure to indicate if the property is
signed and added a int64_t signed_integer to the union.  Updated python binding
to build the correct representation.  I didn't get any feedback on this
approach in the bz, not sure if another approach would work better.

ref. https://bugzilla.redhat.com/show_bug.cgi?id=838257


* Unable to retrieve specific properties:

Any property that internally was defined as a string list was broken, ended up
being a missing flag.

ref. https://bugzilla.redhat.com/show_bug.cgi?id=1139920

Would appreciate someone taking a peek at these changes.

V2: Re-word the commit headers to provide more context.

Thanks,
Tony

Tony Asleson (5):
  lvm2app: Add signed numerical property values
  python: Build correct python value for numerical property
  python: Check for NULL value before constructing string property
  lvm2app: Correct missing string properties
  Python: Improve lv property test coverage

 lib/properties/prop_common.h |  5 +++-
 lib/report/columns.h         |  8 +++----
 lib/report/properties.c      |  3 ++-
 lib/report/report.c          |  2 ++
 liblvm/lvm2app.h             |  4 +++-
 liblvm/lvm_misc.c            |  1 +
 liblvm/lvm_prop.c            |  2 +-
 python/liblvm.c              | 17 ++++++++++----
 test/api/python_lvm_unit.py  | 56 +++++++++++++++++++++++++++++++++++++++++---
 9 files changed, 83 insertions(+), 15 deletions(-)

-- 
1.8.2.1


