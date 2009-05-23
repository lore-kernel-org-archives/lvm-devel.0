From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 22 May 2009 20:04:22 -0400 (EDT)
Subject: Re: LVM command-line interface for shared snapshots
In-Reply-To: <8B4D3601-336A-4D0C-9FC1-E7101F2680F6@redhat.com>
References: <20090514212943.GA25445@redhat.com>
	<Pine.LNX.4.64.0905181136510.22422@hs20-bc2-1.build.redhat.com>
	<095d01c9d7f2$4295a290$c7c0e7b0$@com>
	<20090518222822.GA1319@redhat.com>
	<0ab001c9d809$89ddce90$9d996bb0$@com>
	<Pine.LNX.4.64.0905191636010.19127@hs20-bc2-1.build.redhat.com>
	<8B4D3601-336A-4D0C-9FC1-E7101F2680F6@redhat.com>
Message-ID: <Pine.LNX.4.64.0905221947330.7953@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Wed, 20 May 2009, Jonathan Brassow wrote:

> If we all start replying to this e-mail, it could become pretty fragmented and
> hard to follow.  So, I've taken my thoughts and merged them as best I could
> with what Mikulas has proposed and put them up on the wiki.
> 
> http://sources.redhat.com/lvm2/wiki/FeatureRequests/dm/snapshots
> 
> If people would rather have all discussion on the mailing list, or some
> combination - I'm sure we could do that too.
> 
> brassow

Rename --sharedstore to --exstrore --- probably good thing, it could be 
used even for non-shared stores (although there are not any new and won't 
likely ever be).


prompt> lvcreate -L 1G -n snapshot_cow vg
prompt> lvcreate -s [--exstore persistent|shared|mikulas] [-L <size>] -n
snap vg/origin vg/snapshot_cow

--- the type of the exception store must be specified in the first 
command. Also, if the old scripts should be able to run, they shouldn't 
need to specify the exception store type with each snapshot creation.


prompt> lvremove vg/snap

Description
If 'method 1' was used to create, the last snapshot removed in an
exception store results in the removal of the exception store device. If
'method 2' was used, then the device would be left in place.

--- I thought about this idea too, but rejected it. For admin's 
convenience and for ease of programming scripts, the command behavior 
should be deterministic and dependent on its arguments --- it should not 
depend on some magic flag hidden in the metadata. Think what happens if 
the admin forgets whether he used 'method 1' or 'method 2' to create the 
volume and then becomes confused because lvremove command behaves 
differently. Or if he writes script to remove all the snapshots and later 
the script starts to misbehave because he used different method to create 
the snapshot.

lvremove behavior should be determined by its arguments, not by some value 
stored in the metadata.


About my proposal for "-L" when creating a snapshot --- if we implement 
auto-resizing with dmeventd, we can ignore "-L" at all. I think it would 
be the best thing.


Mikulas


