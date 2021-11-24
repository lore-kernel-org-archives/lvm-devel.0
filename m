From: David Teigland <teigland@redhat.com>
Date: Wed, 24 Nov 2021 08:55:59 -0600
Subject: atime/mtime for VG/PV
In-Reply-To: <CAJNi=XryUgjw3BuiMZV4CX6GSUD7sfLyaa2a-_gpj9f_iH+Yug@mail.gmail.com>
References: <CAJNi=XryUgjw3BuiMZV4CX6GSUD7sfLyaa2a-_gpj9f_iH+Yug@mail.gmail.com>
Message-ID: <20211124145559.GA13560@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Nov 23, 2021 at 04:58:20PM +0100, Marian Csontos wrote:
> Hi folks, as various issues with duplicates are being solved, I wondered if
> it would be beneficial to include things like atime/mtime in metadata.
> 
> Actually mtime is already there in the VG metadata: seqno + timestamp.
> 
> So what would atime be?
> Store a timestamp on activation of an LV in the VG? Write on any lvm
> operation? Or write timestamp more frequently when there are active devices?
> 
> atime should be stored in PV metadata, even if there is no VG MDA - these
> would benefit the most as there is no VG MDA and thus no "mtime".
> 
> When there are duplicates higher atime would be almost certainly the
> correct device, unless user intends to use a LUN's snapshot, but that would
> require an input from user anyway.
> 
> User MUST be able to turn it of ("noatime") in case of being slow for
> hundreds/thousands of PVs.
> 
> Perhaps this would not have to be fsynced all the time, but then there may
> be a chance for mismatch and for snapshot having higher timestamp than
> original PV.

It's interesting, it would be nice to think of some other problem(s) we
could address with it or something like it.  A local file might work in
place of metadata, depending on what it's used for.

The issue of duplicate PVs should soon go away with the devices file in
use.  When the devices file is used, a new cloned/copied PV will often not
be included in the devices file, so lvm won't see it.  But if it is, we
also store the WWID of each PV in the VG metadata, so if there are
duplicates we use the one with the correct WWID.


