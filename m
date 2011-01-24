From: Lars Sjöström <lars.sjostrom@redhat.com>
Date: Mon, 24 Jan 2011 10:58:38 +0100
Subject: liblvm Python/C extension (Python Liblvm)
In-Reply-To: <87oc77tb33.fsf@twilight.int.mornfall.net.>
References: <1295527769.24069.31.camel@ljonsson.local>
	<87oc77tb33.fsf@twilight.int.mornfall.net.>
Message-ID: <1295863118.2970.14.camel@ljonsson.local>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2011-01-24 at 01:11 +0100, Petr Rockai wrote: 
> I am not a python guy myself, but I definitely welcome this. On the
> other hand, as Zden?k points out, this does have some issues. 

Zdenek has indeed a good point! How much work do you guys see to get
this sorted? (implement parameter for non-memlocking to RAM for certain
LVM commands/APIs.)    

> Nevertheless, there's another significant issue, and that is
> maintenance. I can't commit to maintaining python bindings, since I have
> responsibilities besides liblvm and I am a part-timer on LVM -- which
> doesn't exactly leave much space for python (which would necessarily
> include a lot of learning).
> 
> I'll try to talk with the rest of the team about how to best approach
> this. There might be someone with the required python (and python
> binding) skills and enough time. Alternatively, do you think you could
> take the responsibility for the bindings yourself? 

I'm indeed willing to take the maintenance ownership if you don't mind! 

As I said in earlier email, there is still work left. Doc strings,
proper packaging as well as add the new APIs that were released in
December.  

Should I continue and post updates?

Best regards,
Lars





