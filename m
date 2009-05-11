From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 May 2009 02:39:47 +0100
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <87my9ku7t9.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
	<87my9ku7t9.fsf@eriador.mornfall.net>
Message-ID: <20090511013947.GB7680@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, May 10, 2009 at 08:33:22PM +0200, Peter Rockai wrote:
> (The whole non-atomicity of those mirror operation is very unfortunate for
> other reasons, but I didn't yet have time to investigate how hard it would be
> to make those really atomic.)
 
We've two factors here:

  All single-VG command-line-level changes must have a single commit
point with no chance of data/metadata corruption.  (See Rik's lvconvert
bug report.)  pvmove offers a model.

  Not all lvm2 code does everything possible to clean up after an
operation fails.  More code could take the trouble to undo operations
rather than logging error messages telling the admin to remove something
by hand.  More code could detect things left behind by an earlier failed
operation and clean them up transparently.

Alasdair


