From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 24 Jan 2011 17:04:17 +0100
Subject: [PATCH 16/17] Fix pvchange -u to work with recent changes in metadata handling interface.
In-Reply-To: <1295867048-21558-17-git-send-email-prajnoha@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
	<1295867048-21558-17-git-send-email-prajnoha@redhat.com>
Message-ID: <4D3DA301.2090303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/24/2011 12:04 PM +0100, Peter Rajnoha wrote:
> I use PV id as a key for format instance's metadata_areas_index.
> But since we change this one, I still need to work with the original
> one to access the metadata areas (e.g. in pv_write). So, I defined
> the pv->old_id to store that.

One more thing to note. We should probably allow writing non-orphan
PVs directly... The pv_write code calls:

    /* Add a new cache entry with PV info or update existing one. */
        if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,   
                        pv->dev, FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
                return_0;

..that changes any existing cache entry to be "orphaned", even if that
PV is already part of a VG!

The code concerned is in outer pv_write fn that calls format specific
pv_write code:

        if (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count) {
                log_error("Assertion failed: can't _pv_write non-orphan PV "
                          "(in VG %s)", pv->vg_name);
                return 0;
        }

Also, the pvchange -u call is not quite nice today:


          pv->vg_name = pv->fmt->orphan_vg_name;
          pv->pe_alloc_count = 0;
          if (!(pv_write(cmd, pv))) {
                      log_error("pv_write with new uuid failed "
                                          "for %s.", pv_name);
                      goto out;
          }
          pv->vg_name = orig_vg_name;
          pv->pe_alloc_count = orig_pe_alloc_count;


To support calling pv_write on non-orphan PVs, we need to destroy
the old cache item and insert a new one or just update the existing
cache entry. But since the pvid is used as a key to cache pvid hash,
we need to update this entry as well... But I don't see that as a
problem. The change is quite easy, the question is whether it won't
cause any other problems...

Peter


