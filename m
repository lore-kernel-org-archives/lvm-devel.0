From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 20 Feb 2014 10:23:06 +0100
Subject: Deadlock on "systemctl daemon-reload" when using socket based lvmetad activation.
In-Reply-To: <5305BE74.6080101@redhat.com>
References: <20140220001412.41fe5ee5@opensuse.site>
	<5305BE74.6080101@redhat.com>
Message-ID: <5305C97A.7000002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/20/2014 09:36 AM, Peter Rajnoha wrote:
> On 02/19/2014 09:14 PM, Andrey Borzenkov wrote:
>> Details are in https://bugzilla.novell.com/show_bug.cgi?id=862076#c44
>> and following comment.
>>
>> Always starting lvmetad really defeats the idea of socket activation
>> (do not start process until needed) and does not fully eliminate the
>> problem (consider lvmetad crashing in the wrong moment).
>>
> 
> I agree. I'm not even counting much that anybody uses lvmetad by
> enabling the lvm2-lvmetad.service itself (though possible) - this was
> primarily designed to be socket-based activated. The socket-based
> activation should just work under all circumstances. I'll fix that...

Actually, this should be already fixed in lvm2 v2.02.99 with this commit:

https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=983f0b46f2de85b8de0e2d7f8afbdf53f132a87a

-- 
Peter


