From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 06 May 2010 10:13:15 +0200
Subject: [PATCH 01/23] Return ECMD_FAILED for break
In-Reply-To: <20100506011019.GJ27027@agk-dp.fab.redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<1c89a9d6ba2bfb863fb66b02743ccd9fa00f97e5.1272457502.git.zkabelac@redhat.com>
	<20100506011019.GJ27027@agk-dp.fab.redhat.com>
Message-ID: <4BE27A1B.5040503@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.5.2010 03:10, Alasdair G Kergon napsal(a):
> On Wed, Apr 28, 2010 at 02:27:20PM +0200, Zdenek Kabelac wrote:
>> Return ECMD_FAILED when sigint has been caught.
>  
> Might seem reasonable, but this condition is also checked in many other places.
> If we're going to override the return code when a command might have been
> interrupted before it completed, shouldn't we do it consistently everywhere?
> 

Yes there are more inconsitencies like this through the code - but in my
replicator case I've added 'extra' loop around this interrupt check - thus
I've added this fix at this place.

The problem with interrupt check may be possibly bigger - as the semantic is
not really clear - should we always return 'error' when Ctrl+C is hit by the
user? - maybe we should check for sigint before we actually want to iterate
next loop - thus if the 'break' was noticed after processing last loop - we
return 'OK' like no break was seen ?

Zdenek


