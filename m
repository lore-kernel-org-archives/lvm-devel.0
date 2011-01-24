From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:10:22 +0100
Subject: liblvm Python/C extension (Python Liblvm)
In-Reply-To: <1295863118.2970.14.camel@ljonsson.local>
References: <1295527769.24069.31.camel@ljonsson.local>	<87oc77tb33.fsf@twilight.int.mornfall.net.>
	<1295863118.2970.14.camel@ljonsson.local>
Message-ID: <4D3D500E.6080207@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 24.1.2011 10:58, Lars Sj?str?m napsal(a):
> On Mon, 2011-01-24 at 01:11 +0100, Petr Rockai wrote: 
>> I am not a python guy myself, but I definitely welcome this. On the
>> other hand, as Zden?k points out, this does have some issues. 
> 
> Zdenek has indeed a good point! How much work do you guys see to get
> this sorted? (implement parameter for non-memlocking to RAM for certain
> LVM commands/APIs.)    
> 

As we are currently redesigning a bit internal memlock code for some other
reasons, we may think about this support more. But as this piece of code is
quite sensitive and may have some 'hard to check' side effect I expect it take
some time.

Zdenek


