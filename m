From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 15 Feb 2010 17:48:02 -0500
Subject: snapshot: refactor snapshot-merge deptree and device removal
In-Reply-To: <1266273782-32641-1-git-send-email-snitzer@redhat.com>
References: <1266273782-32641-1-git-send-email-snitzer@redhat.com>
Message-ID: <20100215224802.GA32756@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 15 2010 at  5:43pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> Add a merging snapshot using the "error" target rather than avoid
> adding it entirely.  This allows proper cleanup of the -cow device
> without having to rename the -cow to use the origin's name as a
> prefix.
> 
> Moved the preloading of the origin LV, after a merge, from
> lv_remove_single() to vg_remove_single().  Having vg_remove_single()
> preload the origin free up the -cow device so that it can be removed
> via deactivate_lv().  This is reliable because the associated snapshot
> LV, that is to be removed when a snapshot-merge completes, is always
> added no to the deptree (and kernel -- via "error" target).
> 
> Now when the snapshot LV is removed both the -cow and -real devices
> get removed using uuid rather than device name.  This paves the way
> for us to switch over to info-by-uuid queries.

I tested this patch with and without Milan's info-by-uuid patches here:
http://mazyland.englab.brq.redhat.com/test-shared/

Mike


