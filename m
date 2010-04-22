From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 21 Apr 2010 20:01:32 -0400 (EDT)
Subject: Allowing an actively merging snapshot to be removed?
In-Reply-To: <20100421193804.GA28717@redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
	<20100419232509.GG4828@agk-dp.fab.redhat.com>
	<20100421063504.GA10083@redhat.com>
	<20100421193804.GA28717@redhat.com>
Message-ID: <Pine.LNX.4.64.1004211951340.24723@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 21 Apr 2010, Mike Snitzer wrote:

> On Wed, Apr 21 2010 at  2:35am -0400,
> Mike Snitzer <snitzer@redhat.com> wrote:
> 
> >    when a merge is active the merging
> >    snapshot LV is accessible (by user with lvremove); so removing the
> >    merging snapshot is currently allowed (stops merge, deletes
> >    snapshot); should it be allowed?
> 
> Hi Mikulas,
> 
> What are your thoughts on this corner case?
> 
> thanks,
> Mike

I think the merging snapshot LV shouldn't be accessible (I initially coded 
it so that it is renamed and disappears completely). There is nothing that 
the admin can do with the merging snapshot, so you don't have to show it 
in "lvs" output.

You can't allow the admin to delete the merging snapshot. This would cause 
data loss. The origin contains transient data during merge process 
(partially the old and partially the new volume), if you delete the 
merging snapshot and directly access the origin, the result is a mess.

You can assume that the admin doesn't know the exact logic of merging 
(i.e. he may not be aware that deleting the merging snapshot destroys all 
the data on the origin instantly), so you must definitely prevent the 
tools from doing this.

You should allow the admin to delete the origin (and delete the merging 
snapshot with it). You can also allow deleting of other non-merging 
snapshots, while the merge is in progress.

Mikulas


