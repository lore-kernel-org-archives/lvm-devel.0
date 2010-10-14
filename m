From: Milan Broz <mbroz@redhat.com>
Date: Thu, 14 Oct 2010 14:57:17 +0200
Subject: lvconvert: provide useful error when snapshot-merge target missing
In-Reply-To: <20101014125349.GA8079@redhat.com>
References: <20101013185302.GA2944@redhat.com> <4CB6034D.5080603@redhat.com>
	<20101013214257.GC32395@agk-dp.fab.redhat.com>
	<4CB6C782.6020501@redhat.com> <20101014125349.GA8079@redhat.com>
Message-ID: <4CB6FE2D.3010903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/14/2010 02:53 PM, Mike Snitzer wrote:
> On Thu, Oct 14 2010 at  5:04am -0400,
> Zdenek Kabelac <zkabelac@redhat.com> wrote:
> 
>> Dne 13.10.2010 23:42, Alasdair G Kergon napsal(a):
>>> On Wed, Oct 13, 2010 at 09:06:53PM +0200, Milan Broz wrote:
>>>> I think this will break shared (external) segment module ABI.
>>>
>>> Indeed - we make no guarantees for that ABI and don't even bother 
>>> versioning it.  We don't believe there are any out-of-tree users.
>>>
>>
>> I'd propose to drop/turn off this feature completely - targets usually cannot
>> work without heavy tweaking through the rest of the code anyway. So in fact we
>> rather 'pretend' there is such functionality.
> 
> I'm not following what you're saying.  There is no pretending here...
> 
> The feature fails gracefully with an informative error message.
> 
> What's the problem?

I hope just misunderstanding:)

I think Zdenek means shared segment feature,
not your patch & snapshot merge.

If not, I just added my 2 Eurocents to confusion:-)

Milan


