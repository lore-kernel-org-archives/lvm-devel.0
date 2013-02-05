From: thornber@redhat.com <thornber@redhat.com>
Date: Tue, 5 Feb 2013 12:18:47 +0000
Subject: Default low water mark threshold for a new thin pool
In-Reply-To: <87ehgv16gf.fsf@in.ibm.com>
References: <87ehgv16gf.fsf@in.ibm.com>
Message-ID: <20130205121846.GB3082@raspberrypi>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 05, 2013 at 02:30:00PM +0530, M. Mohan Kumar wrote:
> 
> Hello,
> 
> We are adding a lvm2api for creating a thin pool. During thin pool
> creation if user does not specify anything for the low water mark
> thresold, it would result in 0 and no events will be generated when thin
> pool capacity is reaching its full size.

An event will be generated.

> I am not sure what should be the default low water threshold
> percentage. Is there any recommended value for low water threshold value
> in dm thin pools?

It's very hard to say since it depends on your use case.  In general
you want to allow dmeventd plenty of time to extend the pool before
you run out of space.  So if you're seeing a _peak_ provisioning rate of
100meg a minute, I'd set the lwm to about 100meg.  It would be nice if LVM
could help you through this process.

- Joe


