From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:12 -0400
Subject: [PATCH 00/20] Add lvm vg and pv properties for lvm2app.
Message-ID: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a repost and add onto the previous patchset
posted to lvm-devel on 9/15/2010.  It continues that patchset
and adds pv properties and addresses comments made on the vg
patchset.

Notable changes:
1. Refactor parts of metadata.[ch] into {pv|vg|lv}.ch.
2. Added 'const' to 'get' object functions
3. Improve type safety on vg_get_property() and pv_get_property()
4. Add "_dup" suffix to helper functions that allocate/dup strings.

All vg and pv properties may now be queried with this patchset.
The refactoring of metadata.[ch] into specific files was only
done for functions related to report field calculations.  In
the future, further functionality may be moved to these specific
files, and common functions will remain inside metadata.[ch].


