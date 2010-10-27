From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 27 Oct 2010 12:36:58 +0200
Subject: [PATCH 4/5] Fix theoretical usage of NULL pointer dereference
In-Reply-To: <874oc8sztz.wl%ejt@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>	<a1cfd7e4e519a821b545e3a299eb01866ed76877.1288097372.git.zkabelac@redhat.com>	<20101026133743.GI29400@agk-dp.fab.redhat.com>
	<874oc8sztz.wl%ejt@redhat.com>
Message-ID: <4CC800CA.5000206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.10.2010 12:19, ejt at redhat.com napsal(a):
> At Tue, 26 Oct 2010 14:37:43 +0100,
> Alasdair G Kergon wrote:
>>
>> On Tue, Oct 26, 2010 at 02:59:25PM +0200, Zdenek Kabelac wrote:
>>> @@ -97,6 +97,12 @@ int ttree_insert(struct ttree *tt, unsigned int *key, void *data)
>>
>>> +	if (!*c) {
>>> +		log_error(INTERNAL_ERROR "Insert failed.");
>>
>> What am I missing here?
>> Isn't that condition you are proposing to add logically impossible to
>> trigger?!
> 
> Yes, it can't happen, as I said the first time this patch went round.
> 
> One thing I'm not clear on is how much benefit we're seeing from the
> CLang build?  Kabi, how many genuine bugs did you find when you went
> through this process?  If the benefits are real, then we can live with
> check like these.  It would be nice if it was clearer that they are
> only there to pacify clang, maybe put a conditional compile in so
> they're only included with the clang build?

>From the first original patchset real bugs are already commited.
I think patches 4, 5, 10, 14, 15.  (Some of them are clearly problems of
missing deep unit tests probably - but running scan-build - or spending
months writing tests for every single error path in the code - I think we do
not have manpower for this at this moment...)

The problem here is not what would happen if everything goes 'right', but what
could happen if something goes 'wrong' - i.e. we may overwrite
some bytes in memory by some other errors, we may leave some structure in
wrong state, because of some unchecked error path - we could misuse or wrongly
reuse something- obviously we will need to find the real cause of such memory
overwrite - but the question is - is it the best thing to generate a coredump
- or should we nicely bailout from such case  and give user some  error report?

I didn't want to spend too much time with this thing in first place - so I've
chosen easiest path here - and as mention in the patchset header - under
normal circumstances lots of those (sometimes really crazy code paths) are not
reachable - but if these checks are so cheap - why not add them -  we do not
mask the bug - we just avoid coredump for this case.

Zdenek


