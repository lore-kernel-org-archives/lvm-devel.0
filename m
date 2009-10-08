From: Petr Rockai <prockai@redhat.com>
Date: Thu, 08 Oct 2009 11:42:30 +0200
Subject: [PATCH 02/13] Replicator: add libdm support
In-Reply-To: <20091007143959.GB3054@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 7 Oct 2009 15:39:59 +0100")
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<20091007143959.GB3054@agk-dp.fab.redhat.com>
Message-ID: <874oqa9q7t.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> On Mon, Oct 05, 2009 at 04:00:29PM +0200, Zdenek Kabelac wrote:
>>  int dm_tree_suspend_children(struct dm_tree_node *dnode,
>> -				   const char *uuid_prefix,
>> -				   size_t uuid_prefix_len);
>> +			     const char *uuid_prefix,
>> +			     size_t uuid_prefix_len,
>> +			     int priority);
>   
> We can't change the published interface like that.
>
> If there really is no alternative to this parameter then you need to introduce
> a new function instead.
I have discussed this in person with Zden?k, and it seems that the main reason
for this is to allow more atomic suspension of complete replicator.

The normal semantics of DM tree operations is that suspension of a node is done
after all its children are suspended. For replicator, it would be beneficial to
suspend the parent first (to stop the IO stream from the client side) and only
afterwards start suspending the inferior nodes.

In practice, this constitutes only a very slight increase in risk of tripping a
"synchronicity" threshold -- by the amount of data that arrives to the
replicator head in the time frame between a leg is suspended and the replicator
as a whole is suspended -- if this extra data exceeds the amount of free space
in the replicator log, this could trip an extra resync that would be
costly. But it should be stressed, that in these situations, this was already
quite likely to happen, and the outlined problem only increases the chance of
this happening by a small margin.

In other words, I think it is not worth worrying about just yet. At the point
when a dmeventd-style leg dropping is implemented for replicator, this may
become a more pressing problem, but I think the solution should be deferred
until the work on that aspect has begun -- at that time, we ought to have a
clearer picture of the problem area, so it may turn out that a better solution
exists that would not require similar incompatible (and arguably risky) changes
to the libdm core.

Yours,
   Petr.


