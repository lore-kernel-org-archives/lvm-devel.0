From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 9 Nov 2006 21:18:04 +0000
Subject: Re: [linux-lvm] Proposal for the libLVM project
In-Reply-To: <455431FB.3070701@kix.in>
References: <455431FB.3070701@kix.in>
Message-ID: <20061109211804.GL30653@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks for getting in touch.

The only library supported for external applications at present is
liblvm2cmd and this is basically a wrapper around the command line.
This was a deliberate decision to force people to use the only stable interface
we have, namely the command line.

The lvm library that came with the original version of LVM had many problems
and when we began LVM2 we made the decision not to offer a library until the
code base and interfaces settled down.  We've had discussions (undocumented
unfortunately - snippets on irc and face-to-face discussions) about what
form the library API should take and reached a basic consensus.  Every
change made to the code is done with these plans in mind.
More recently, we've been moving some functions out of lvm and into
libdevmapper - which is a supported library interface.

The current split between the 'lib' and 'tools' directory is not
particularly well-defined at the moment, and there's some more code
in 'lib' that should be in 'libdevmapper', behind a decent interface.


The end result should be:

  a new lvm library API exists which is designed to be maintainable as the
tools develop and not cause compatibility problems or inhibit anticipated
future developments;

  the tools directory uses only the published API;

  everything available in the API is available directly through the lvm
command line - there must be no 'hidden' features;

  no internal structures are exposed through the library API so we retain
complete freedom to change internal implementations and data structures.

Note that last one carefully - structures in metadata.h are not to be
exposed directly: the file is still very much a 'work in progress'.
PV and LV structures are gradually merging; the VG concept is undergoing
change - and this will all be done without breaking the existing
command line interface, though there'll be extensions to it, and the
library has to be similarly stable and maintainable.  The existing
liblvm.a is not the right basis to base this work on - if anything,
what's happening is a supportable wrapper library is being designed
over the top of it.

So yes, I'm anticipating something object-based: get a handle for a PV,
create a VG by supplying handles for the PVs to go into it and getting a
handle for the VG back.  Get properties of an object by supplying the
appropriate method with the appropriate handle etc.


The first job is to sketch out possible interfaces for some examples
like that - 'create a PV', 'create/extend a VG' - based on what the tools
do today.

Further, if there are things that parted wants that are not available
through the command line today, then put those on the table ASAP and
we should try to get them implemented through the command line (in parallel
with work on designing a library).


There's a separate mailing list for LVM development (which I'll announce
properly in another message), and further discussion should happen there:
please remove linux-lvm from follow-ups about the details of the library.

  https://www.redhat.com/mailman/listinfo/lvm-devel

Alasdair
-- 
agk at redhat.com


