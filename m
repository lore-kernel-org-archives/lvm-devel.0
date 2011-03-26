From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 26 Mar 2011 14:04:43 +0100
Subject: [PATCH 1/3] Fix mem
In-Reply-To: <4D8DB905.7020100@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>
	<e943c109d457bd2cc89c836ae810ec9b8c7bb8f3.1301089240.git.zkabelac@redhat.com>
	<4D8DB905.7020100@redhat.com>
Message-ID: <4D8DE46B.2060705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.3.2011 10:59, Milan Broz napsal(a):
> On 03/25/2011 10:57 PM, Zdenek Kabelac wrote:
> 
>> -		unlock_and_free_vg(cmd, vg_from, vg_name_from);
>> -		unlock_and_free_vg(cmd, vg_to, vg_name_to);
>> +		unlock_vg(cmd, vg_name_from);
>> +		unlock_vg(cmd, vg_name_to);
>> +		free_vg(vg_to);
>> +		free_vg(vg_from);
> 
> I guess there is still request to do proper deep copy...
> 
> Anyway, this is so simple and obvious for now -> ACK


In fact there is even simpler version - to always unconditionally unlock and
free VGs in this order:

--
unlock_and_free_vg(cmd, vg_to, vg_name_to);
unlock_and_free_vg(cmd, vg_from, vg_name_from);
--

This simplifies and shortens the code a bit ;). 'vg_to' is always released
before 'vg_from' - if we make this a documented rule in the source code - we
currently avoid the need of deep copy (It would quite complicate our code, to
add such 'deep' copy code to every target - as we are not in C++ - it's quite
ugly task to do).  As long as we only move object pointers from 'vg_from' to
'vg_to' it's safe - and we may even avoid partial 'deep' copy of some object
there - if we can count with the right free_vg() order.
(Also implementing of deep-copy only for very occasionally used vgmerge and
vgsplit currently sound like a bit to complex).

AFAIK - for deadlock-less locking - only the locking order is important,
unlocking could happen in any order as long as all locks are always released
before the next usage - so current unlock ordering is not needed.

Zdenek


