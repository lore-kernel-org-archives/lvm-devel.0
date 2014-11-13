From: Stéphane Aulery <saulery@free.fr>
Date: Thu, 13 Nov 2014 21:04:47 +0100
Subject: lvmcache.7.in: fix syntax error (line continuation \\)
In-Reply-To: <20141113170636.GA4876@redhat.com>
References: <1415795977-4518-1-git-send-email-saulery@free.fr>
	<1415795977-4518-3-git-send-email-saulery@free.fr>
	<5464E285.3060406@redhat.com> <20141113170636.GA4876@redhat.com>
Message-ID: <20141113200447.GB4267@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Le jeudi 13 novembre 2014 ? 11:06:36, David Teigland a ?crit :
> On Thu, Nov 13, 2014 at 05:55:33PM +0100, Zdenek Kabelac wrote:
> > >-.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV \\
> > >-.br
> > >-.RS
> > >-.B VG/CacheDataLV
> > >-.RE
> > >+.B lvconvert \-\-type cache-pool \-\-poolmetadata VG/CacheMetaLV VG/CacheDataLV
> > >
> > >  .I Example
> 
> I've removed the line continuation mark.

Thanks !

-- 
St?phane Aulery


