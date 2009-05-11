From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:13 -0400
Subject: [PATCH 0/30]: liblvm object property baseline, take2
Message-ID: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following 30 patches supercede the previous 8 patch posting and
implement a baseline for liblvm objects and their properties.  The primary
focus/goal of these patches are:
1. Define / clarify the main liblvm objects and their handles
2. Get the numeric object properties for a specific handle
3. Convert reporting commands to call liblvm 'get' functions for 'NUM' fields

Together with the handles, the 'get' functions will provide equivalent
functionality to the reporting commands (pvs, vgs, lvs) while keeping with
the object model of liblvm.

This set of patches converts most all numeric reporting field 'disp' functions
to call into liblvm 'get' property functions.  There should be no functional
change after this patch, and I believe this patchset, while lengthy, should
be relatively easy to review.

The bulk of this patchset involves a couple changes for each field:
1) moves the logic of the field data calculation from the 'disp' function
into liblvm 'get' function
2) adds a 'disp' function for fields with simple dereferences (these were
originally covered by the same 'disp' function (for example, _uint32_disp())

There are a few areas of particular interest in this patchset.  First, the
return types for all the 'get' functions are the same at uint64_t.  This would
allow internal changes to field sizes without making them visible in the API
but also obscures the internal type size.  I could easily make the internal
size match the return type of the 'get' function if this is deemed the better
tradeoff, but I thought fixed uint64_t was decided in a previous discussion.
Second, a couple numeric fields were ommitted from this patch: snap_percent,
and copy_percent.  These fields involve a float value and so will be dealt
with in a later patchset.

Along with this patchset I've been adding nightly tests to cover some of the
numeric reporting fields not yet covered.  We are still missing a few fields
in the nightly tests and some deserve better coverage but we are getting
closer to full coverage.

This set of patches pass the nightly test suite.
They apply cleanly against the following commit:
commit 97e41de23f5a021dfba8fb16692a9e2badec7d56
Author: Milan Broz <mbroz@redhat.com>
Date:   Mon May 11 10:35:00 2009 +0000

    Fix previous commit (scripts/Makefile targets order)



