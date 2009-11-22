From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 22 Nov 2009 21:31:23 +0100
Subject: Re: [PATCH 2/5] libdm-deptree-return-failure-suspend-children
In-Reply-To: <20091121022631.GB32715@redhat.com>
References: <1258752552-1589-1-git-send-email-snitzer@redhat.com>	<1258752552-1589-2-git-send-email-snitzer@redhat.com>	<4B071ECD.4090500@redhat.com>
	<20091121022631.GB32715@redhat.com>
Message-ID: <4B099F9B.7060200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 21.11.2009 03:26, Mike Snitzer napsal(a):
> On Fri, Nov 20 2009 at  5:57pm -0500,
> Zdenek Kabelac <zkabelac@redhat.com> wrote:
> 
>> Dne 20.11.2009 22:29, Mike Snitzer napsal(a):
>>> Return error immediately to dm_tree_suspend_children() callers.
>>>
>>> Otherwise suspend_lv and its variants can fail silently.
>>>
>>> Signed-off-by: Mike Snitzer <snitzer@redhat.com>
>>> ---
>>>  libdm/libdm-deptree.c |    5 +++--
>>>  1 files changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
>>> index bb10fe5..6f5355d 100644
>>> --- a/libdm/libdm-deptree.c
>>> +++ b/libdm/libdm-deptree.c
>>> @@ -1109,7 +1109,7 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
>>>  			log_error("Unable to suspend %s (%" PRIu32
>>>  				  ":%" PRIu32 ")", name, info.major,
>>>  				  info.minor);
>>> -			continue;
>>> +			return 0;
>>>  		}
>>
>>
>> This is a bit hard to tell what's the right way here - either to continue
>> suspending  'the rest of the monster' or to stop with the first failure.
>>
>> In case of the replicator - when suspend of one head would fail - I would
>> probably prefer to see the code to continue suspending remaing heads.
> 
> OK, the other possibility that Alasdair and I discussed is that we could
> return failure once all nodes at the same level have been processed.
> 
> Would that work for replicator?  Are all heads at the same level in the tree?

Yes - that would probably work well for replicator (though the error in the
suspend as rather hypothetical in this case anyway)

But - still - is it the best thing to stop suspending elements from tree - if
one path fails?

Zdenek


