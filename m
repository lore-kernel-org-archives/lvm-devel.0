From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:31 -0400
Subject: [PATCH 00/38] Add full metadata balancing support, v6.
Message-ID: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a sixth (and hopefully last) round of the metadata
balancing support, makes minor revisions and builds on the fifth
round of patches submitted (6/21/2010).  There are still some
FIXMEs in the code but this is now a complete patchset for the
metadata balance feature.

Changes from the fifth round are spread around but mostly start
around patch 22 and involve the vg support:
1) vgmetadatacopies valid values.
On the commandline of vgcreate/vgchange, we will accept a
non-zero value, "all", and "unmanaged".  See the vgcreate,
vgchange, and lvm.conf man pages for a full description.
The default value of "unmanaged" means LVM will not attempt
to change the 'metadataignore' flags.
2) vgs and pvs report fields.
The fields in the previous patches were called 'pv_mda_count_ignored'
and 'vg_mda_count_ignored'.  This has been changed to reverse
logic of 'vg_mda_used_count' and 'pv_mda_used_count', which counts
the number of mdas in use (not ignored).  This is most likely what
users would care about.
3) Fixed interaction with vgmetadatacopies and pvchange --metadataignore.
Users may want to specify which PVs they want to ignore mdas.  If they
do this, the value of vgmetadatacopies stored on disk is updated to
vg_mda_used_count, that is, if the mdas are being unignored, the
count of in-use mdas is increased, and if they are being ignored,
the count is reduced.
4) More test cases added.

Passes full test suite, and I manually checked a few values with
lvm.conf, including "unmanaged" and a numeric value for vgmetadatacopies.


