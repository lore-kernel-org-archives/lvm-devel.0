From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 23 Jun 2010 09:50:47 -0400
Subject: Concerns about metadata balance downgrading / backwards compatibility
Message-ID: <1277301047.9289.18.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In review of the metadata balance patches, concern was raised about
backward compatibility.  In particular, the following questions were
raised:

Q. How does the user "go back" to a previous revision of lvm if he's
been using metadata balancing?
A: If the user wants to use an old version of the lvm tools, he SHOULD
use "vgchange --vgmetadatacopies N", where N >= vg_mda_count (number of
mdas across all PVs in the VG).  The reason this is recommended is so
that all mdas contain the latest version of the metadata.  If he does
not do this, when using the old tools, it will still work, but he will
get a warning that the VG is inconsistent.  Even in this case though,
the next time the metadata is written, it will be written out
consistently, with a message stating the older copies of metadata have
been updated.

Q: Won't the 'ignore' bits in the mda_header and/or the
"metadata_copies" value written in the VG metadata cause problems with
older LVM tools?
A: No.  The placement of the 'ignore' bits was done in a location on
disk in the mda_header that was previously a 'filler' field (see patch
#1).  As such, the value of the field is irrelevant to previous LVM
versions.  As far as the VG metadata, LVM is written to disregard fields
it does not understand in the VG metadata, so older tools will not parse
the "metadata_copies" field/value, and will not write it back out the
next time an LVM operation updates the metadata.

I think this addresses the compatibility concerns, without need for
further patches.  If there are other specific concerns, please let me
know.

Thanks.


