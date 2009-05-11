From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 May 2009 02:54:48 +0100
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
Message-ID: <20090511015448.GC7680@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 06, 2009 at 04:42:59PM +0200, Milan Broz wrote:
> This can violate VG max_lv restriction on LV.

I'm not bothered if the code exceeds max_lv temporarily.
I mean, does anyone have a real-world use case for that parameter?
(Perhaps make it so VGs exceeding that limit can still be manipulated
internally, but users cannot add new LVs until it drops below the
limit i.e. a soft limit enforced on the user.)

This comes back to whether we actually need the distinction between
TOPLEVEL (nothing in lvm uses the LV) and VISIBLE (it's for users/tools
to open) or not, a distinction we've been eliminating I think.

(If we got automatic clean-up of incomplete multi-step operations
wouldn't the problem go away?  Might be as simple as flagging LVs as
temporary/uncommitted in the metadata and having them deleted next time
the VG lock is taken in the same way as we deal with multiple metadata
sequence numbers in different VG mdas.)

Alasdair


