From: Peter Rajnoha <prajnoha@redhat.com>
Date: Sat, 27 Mar 2010 00:01:35 +0100
Subject: [PATCH] Fix vg_write/vg_commit to not reset position in metadata ring buffer on vgrename
In-Reply-To: <1269620108.2508.3.camel@f10-node1>
References: <4BACBD1F.80101@redhat.com> <1269620108.2508.3.camel@f10-node1>
Message-ID: <4BAD3CCF.1060302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/26/2010 05:15 PM, Dave Wysochanski wrote:
>> When looking for a location where to put metadata next, we're given a NULL value because
>> of failed VG name comparison (in _find_vg_rlocn) between the name in existing metadata
>> and metadata we're just about to write.
>>
>> This resets the position in the ring buffer, overwriting any existing metadata
>> (and also incorrectly updates the cache to "orphan" afterwards).
>>
>> This patch just adds old_name item in struct volume_group that we can check and use
>> if necessary and detect renames at lower layers as well.
> 
> Seems reasonable.
> 
> But while we're on this topic, can you explain why _find_vg_rlocn() is
> necessary at all?
> 
> Why are we not just using a precommit or non-precommit area here.  This
> whole function looks like a hack and it makes some things harder.  IMO
> if we could get rid of it we'd be better off.
> 

Hmm, there's also the vgcfgrestore that has a very similar problem like the vgrename.
But for the vgcfgrestore to write metadata correctly too, we would probably need
to disable this VG name check (as discussed with Alasdair today), so actually we have
3 situations:

 - normal vg_write/vg_commit while changing VG
 - vgrename
 - vgcfgrestore

For the check to be correct we have vg->name for the first case. For the second one,
we need that vg->old_name I tried to add. But I was still thinking about the third one.
If we were to support that, we would need to disable that check (we don't do full vg_read
on vgcfgrestore). But how would _find_vg_rlocn know this is the situation? How to pass
that information from the "layer" above through vg_write/vg_commit? Adding another
item into struct volume_group (or elsewhere)? That would be messy.

So yes, your question is probably right. If that check was not so essential and its
removal didn't break anything, it would probably make things much more simple and clean.

Whether the check we do in that _find_vg_rlocn is really worth it... Hmm...

Peter


