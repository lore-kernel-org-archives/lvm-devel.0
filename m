From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 17 Aug 2009 09:32:51 -0400
Subject: [PATCH 14/14] Update lvm2app.h prototype to describe restrictions for alphabetical locks.
In-Reply-To: <1250515971-8240-1-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
	<1250515971-8240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1250515971-8240-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If we move to the alphabetical lock ordering mandate within LVM, this will
impact liblvm.  One way to make liblvm comply is to only allow an application
to create/open a single VG at any time.  The other option is to allow an
application to have multiple VGs open, and fail the calls if they get the
ordering wrong.  I suppose a third approach is a slight variation on the second
one, with liblvm handling lock release and reobtain with the correct order.
This patch takes the first approach.

The implications of taking this approach is now we have a hybrid object/cmdline
liblvm model for some operations.  Operations involving more than 1 VG are
probably not in the 20% of the 80/20 rule, so perhaps not a big deal.  We will
have to deal with all the commandline options in these calls.  Fortunately,
commandline options that would create further complexity are limited to
vgsplit (vgmerge is trivial).  Thus, we impose further restrictions on vgsplit:
1. You must split into an existing VG.  For the most part this is fine, but it
does cause a problem if the new VG was to only contain devices from the source
VG.  We could actually support this if we allowed multiple VGs to be open
at a time, and allowed the vgcreate call to go through, followed by a
vgsplit.  Then we'd have to handle implicit lock re-ordering though.  With
this patch's approach, split into a new VG is just not supported.
2. The -n option will be supported in a separate liblvm call(s).  For this
one, we could provide an API to return a list of devices associated with one
or more LVs, or we could just leave this to the application for now.

A final word of caution if we take this approach.  At this point it is unclear
to me that vgsplit/vgmerge would be the only multi-VG operations we'd ever
want to support.  So we could find ourselves creating another non-object based
function in the future.  While I'm not really keen on trying to plan/forsee
the unknowable, this seems to be a real possibility to consider with this
design approach, unless we are fairly certain vgsplit/vgmerge would cover the
multi-vg operations.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm2app.h |   50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index 02b5d76..05e4f5e 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -61,6 +61,13 @@
  * close the VG and re-open with WRITE permission. It should then check
  * whether the original "vg_seqno" obtained with READ permission matches
  * the new one obtained with WRITE permission.
+ *
+ * Limitations
+ * 1. Only one VG allowed open at any time.
+ * The LVM library currently enforces the restriction of a single VG open at
+ * a time.  This rule is enforced by failing any function that opens or
+ * creates a VG.  The list includes lvm_vg_open, lvm_vg_create, lvm_vg_split,
+ * and lvm_vg_merge.
  */
 
 /**
@@ -462,6 +469,49 @@ int lvm_vg_extend(vg_t vg, const char *device);
 int lvm_vg_reduce(vg_t vg, const char *device);
 
 /**
+ * Split a VG into a second VG by moving devices (and any LVs) to the new VG.
+ *
+ * This function will split an existing VG into a second VG by moving devices
+ * from the source VG to the destination.  Note that no storage is copied
+ * during the move, so whole LVs must be moved at a time.
+ *
+ * \param   vg_name_src
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   vg_name_dest
+ * Name of new volume group to split into.  The VG may be a new or existing VG.
+ *
+ * \param   devices
+ * Array of device names to move from vg_name_src to vg_name_dest.
+ *
+ * \param   device_count
+ * Count of devices to move.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_split(const char *vg_name_src, const char *vg_name_dest,
+		 const char **devices, uint32_t device_count);
+
+/**
+ * Merge two VGs into a single VG.
+ *
+ * This function merges an existing source VG into a destination VG by moving
+ * devices from the source to the destination.
+ *
+ * \param   vg_name_src
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   vg_name_dest
+ * Name of new volume group to split into.  The VG may be a new or existing VG.
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_merge(const char *vg_name_src, const char *vg_name_dest);
+
+
+/**
  * Set the extent size of a VG.
  *
  * This function requires calling lvm_vg_write to commit the change to disk.
-- 
1.6.0.6


