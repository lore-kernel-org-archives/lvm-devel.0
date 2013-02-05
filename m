From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Tue, 05 Feb 2013 14:30:00 +0530
Subject: Default low water mark threshold for a new thin pool
Message-ID: <87ehgv16gf.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hello,

We are adding a lvm2api for creating a thin pool. During thin pool
creation if user does not specify anything for the low water mark
thresold, it would result in 0 and no events will be generated when thin
pool capacity is reaching its full size. IMHO, if user does not specify
anything during thin pool creation, we can assume some value something
like 25%, so that when a thin pool is consumed more than 75%, there will
be an event generated for that pool.

I am not sure what should be the default low water threshold
percentage. Is there any recommended value for low water threshold value
in dm thin pools?

Regards,
M. Mohan Kumar 


