From: David Teigland <teigland@redhat.com>
Date: Thu, 13 Nov 2014 11:06:36 -0600
Subject: lvmcache.7.in: fix syntax error (line continuation \\)
In-Reply-To: <5464E285.3060406@redhat.com>
References: <1415795977-4518-1-git-send-email-saulery@free.fr>
	<1415795977-4518-3-git-send-email-saulery@free.fr>
	<5464E285.3060406@redhat.com>
Message-ID: <20141113170636.GA4876@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 13, 2014 at 05:55:33PM +0100, Zdenek Kabelac wrote:
> >-.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV \\
> >-.br
> >-.RS
> >-.B VG/CacheDataLV
> >-.RE
> >+.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV VG/CacheDataLV
> >
> >  .I Example

I've removed the line continuation mark.


