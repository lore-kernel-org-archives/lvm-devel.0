From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 20 Jan 2011 16:24:22 +0100
Subject: liblvm Python/C extension (Python Liblvm)
In-Reply-To: <1295527769.24069.31.camel@ljonsson.local>
References: <1295527769.24069.31.camel@ljonsson.local>
Message-ID: <4D3853A6.1010209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.1.2011 13:49, Lars Sj?str?m napsal(a):
> Hello,
> 
> I was missing a proper LVM2 interface to Python so I decided to write
> one my self! I have wrapped all the liblvm C APIs (excluding the new
> APIs committed in Dec). Doc strings are still missing, as well as proper
> setup.py build env, so consider it as work in progress.
> 
> This might also be interesting to other projects like Anaconda for
> example.
> 
> I would love to get your feedback on it!
> 
> Best regards,
> Lars 


I can see at least one problem - which needs to be addressed somehow.

Operations like lvremove are currently locking whole executable
to RAM - which is reasonable small (20MB) in case it's just native lvm binary,
but it may get unusable huge when Python steps in the game.

If the lvm2api is going to be used this way - we will need to add
some option  which would disable memlocking for this code - and user would
need to enable it probably explicitly.

Zdenek


