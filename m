From: David Teigland <teigland@redhat.com>
Date: Tue, 26 Mar 2013 17:50:01 -0400
Subject: pvresize problem
In-Reply-To: <20130326165913.GA12503@redhat.com>
References: <20130326165913.GA12503@redhat.com>
Message-ID: <20130326215001.GA15037@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 26, 2013 at 12:59:13PM -0400, David Teigland wrote:
> I'm trying to verify shrinking with pvresize --setphysicalvolumesize
> 
> When the pv is an orphan, it works as expected, but when the pv is
> not an orphan, the resulting size is always 8192S less than the
> requested size.

Looking in _text_pv_resize(), I'm guessing the difference I see might be
"pv->size -= size_reduction" which would indicate things are working as
intended.  If so, I'll adjust my checks to include this reduction.


