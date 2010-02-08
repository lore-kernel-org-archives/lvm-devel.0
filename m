From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 08 Feb 2010 16:01:01 +0100
Subject: Suppress locking initialisation failure messages when --ignorelockingfailure is used
In-Reply-To: <20100208145515.GB20595@redhat.com>
References: <4B700EDC.7020505@redhat.com>
	<4B701284.1030606@redhat.com>	<20100208134605.GA16433@redhat.com>
	<4B702169.2000405@redhat.com> <20100208145515.GB20595@redhat.com>
Message-ID: <4B70272D.7060005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/08/2010 03:55 PM, Mike Snitzer wrote:
> Shouldn't rc.sysinit's "vgchange -a y --ignorelockingfailure" come
> _after_ root's rw remount?
> 
> Dracut has already taken care of activating any LVs needed for the root
> FS.  What advantage is there in trying to activate other (non-root) LVs
> before root is rw?

Yes, I'm just asking the same questions, too :) It seems to me there's no
reason to call it before the remount. So maybe editing rc.sysinit a little
would provide us a cleaner solution...

Peter


