From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 16 Jul 2009 23:11:34 +0100
Subject: Re: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to pad aligned data area
In-Reply-To: <20090716205357.GB9005@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
	<1247515882-13736-2-git-send-email-snitzer@redhat.com>
	<20090716151153.GD32757@agk-dp.fab.redhat.com>
	<20090716205357.GB9005@redhat.com>
Message-ID: <20090716221134.GE32757@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The difficulty is that lots of code paths converge here.
Cases where there are pre-existing mdas that must be preserved.
Cases where there is a pre-existing pe_start that must be preserved.
Cases which back up the existing setting of pe_start and restore
it after returning - the mdas had better not have moved to overlap.
pe_start is kept in two places on disk - inside the PV header
(as the data area location) and inside the VG metadata if the PV
belongs to a VG.  The latter could mask the former.

E.g. Did you test pvcreate with some new offset; add to VG; vgcfgrestore
from a backup that did not have an offset when it was created; vgremove;
and see whether the original offset got preserved?
Then throw a pvchange --uuid into the sequence just before the vgremove.
And test conversion from/to lvm1 format.

These are examples of code paths touched by the patch which should all be
retested.

Alternatively go for a rule-based patch ("wherever it currently does X now also
do Y") that avoids the need to audit and test all those code paths thoroughly.

Or if you want to move the place pe_start is set and you have audited/tested
the code, do that as a separate patch prior to incorporating the new setting.

Also, we need a crisper definition of this new setting and how it interacts
with the existing alignment code (page size, data_alignment, pe_align,
md_chunk_alignment etc.) 
What's the behaviour if someone gives a value much larger than the
calculated pe_align?
Are we sure it's never applied twice e.g. with multiple invocations
of the code (in any combination of the cases I mentioned above) pe_start
doesn't grow bigger and bigger?  
Should the first mda get extended to fill up any free space prior to pe_start?

Alasdair


