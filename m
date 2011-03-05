From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Sat, 05 Mar 2011 12:44:56 +0100
Subject: [PATCH 2/2] Do not send random bytes in message
In-Reply-To: <20110304204233.GN10767@agk-dp.fab.redhat.com>
References: <cover.1299089143.git.zkabelac@redhat.com>	<8c22247db5625256cf453a8ee775789cf5b22417.1299089143.git.zkabelac@redhat.com>
	<20110304204233.GN10767@agk-dp.fab.redhat.com>
Message-ID: <4D722238.2000002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 4.3.2011 21:42, Alasdair G Kergon napsal(a):
> On Wed, Mar 02, 2011 at 07:09:08PM +0100, Zdenek Kabelac wrote:
>> struct clvm_header contains 'char args[1]' - so adding '+ 1' here
>> for the message length calculation is not correct - we end up with longer
>> message where last byte is uninitialized and passed to write function.
>  
> What are the implications beyond the immediate line of code changed?

All messages will have consistent form and will no contain random
(uninitialized) data in their body.

It may mean it will 'leak' some bytes from reallocated memory pool, however we
do not release any sensitive data and leak bytes are very short sequences,
there is IMHO no security problem.


> 
>> xid and clintid are initialized to 0.
>  
> What are the implications of not setting these to 0?

Currently I'd say that only sending of random data in messages and producing
valgrind warnings with each code run.

Of course, it's probably more wide spread through the clvmd code than my
current patch set fixed - I'm planning to add few more later...

As 'char args[1]' in clvmd_header is defined as taking 1 byte (common tactic
is probably to use there 'char args[0]' - but this change would require much
bigger rewrite) - data are written already at position [0] - not after the
sizeof(clvm_header) so it's commonly used this way:
   - message_len =  sizeof(clvm_header) + strlen(added_chunks) + 1.
this way the last byte is actually not set and left in a form which came from
memory allocation. As the size of the message is deduced from 'arglen'
variable - stripping the message from the last random value byte should not
cause problems.

Another problem in this code seems to be that some parts of clvm_header are
left undefined (using values from allocated memory chunk - usually xid) - I
hope it's not part of protocol desing to use such randomness inside the
message - from my code check it's probably only issue for local messages where
this values are ignored.

Zdenek


