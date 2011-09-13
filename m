From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 13 Sep 2011 13:29:36 -0500
Subject: [PATCH] Retry dm device removal if busy
In-Reply-To: <4E6F6958.5020609@redhat.com>
References: <4E6F6958.5020609@redhat.com>
Message-ID: <6E8B2169-8A1D-4682-B02E-9CEA8D1B6835@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Yes please!

All to often we come across this issue.  There are a number of bugs that are likely fixed by doing this change - even if it isn't academically perfect.

 brassow

On Sep 13, 2011, at 9:31 AM, Peter Rajnoha wrote:

> If a dm device is being opened in parallel while we're
> trying to remove it, we'll end up with an error that
> the device is busy. This is a legitimate error, but
> with udev in play and asynchronous events generated
> as a result of using the WATCH udev rule, we can get
> into a situation where such failure is very unpleasant.
> 
> Let's try the removal a few times then. Though this is
> not a complete solution to the problem, let's use this
> until we have one.
> 
> Peter

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110913/f1201b63/attachment.htm>
