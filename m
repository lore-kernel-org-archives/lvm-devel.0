From: Eric Ren <zren@suse.com>
Date: Tue, 8 Aug 2017 10:03:58 +0800
Subject: lvmlockd: adopt locks always failed
In-Reply-To: <20170807154739.GB4875@redhat.com>
References: <107b2602-3918-fdbe-6645-da7a2c29e0e9@suse.com>
	<20170807154739.GB4875@redhat.com>
Message-ID: <59570f35-a284-dca3-983b-22bf3addf4f7@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

On 08/07/2017 11:47 PM, David Teigland wrote:
>> The problem here seems we should not ask sanlock for left lockspaces when
>> it's not running?
> Yes, thanks for debugging that, I've just pushed a fix.
Thanks!

I add a resource agent for lvmlockd. It would be great if you can give some
review and comments there ;-P  The PR is here:

https://github.com/ClusterLabs/resource-agents/pull/1013

Regards,
Eric


