From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Jul 2010 09:56:11 -0400
Subject: [PATCH 0/4] Add generic attribute function for vg attributes, v1.
Message-ID: <1279720575-27485-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a rebase/update of previous patches posted for
a generic attribute function for the reporting infrastructure
and liblvm.  I'm not entirely happy with this approach.

Still TODO:
1. Documentation of the field names and descriptions.  This seems
necessary as they are no longer documented in the function name,
and requiring the user to go to the man page and the help output of
the vgs/pvs/lvs commands seems unreasonable.
2. A similar function for PV and LV.


