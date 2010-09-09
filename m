From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Sep 2010 16:12:57 -0400
Subject: [PATCH 00/12] Add lvm vg properties for lvm2app.
Message-ID: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a continuation of the prior patchset to implement
generic functions to query a value of a field in an lvm report.
This patchset completes the vg-based fields of the report and adds
a generic function, lvm_vg_get_property() to lvm2app to query the
properties by name.

For the string-based properties, memory allocation is done inside
the individual supporting functions (i.e. vg_name(), vg_uuid(), etc).
I decided this to be the best approach for consistency sake, and
since some of the properties (for example, vg_attr, and vg_uuid)
required special formatting and thus required the allocation to be
done at the lower level.

I'm not entirely happy with this patchset but it is close enough.
In particular, some of the functions might be better placed inside
a separate file in lib/report and then shared between report.c
and properties.c.  For now I've placed most of the functions inside
metadata.c.

Once this patchset is accepted and committed, I shall continue with
the pv and lv properties using the same approach.


